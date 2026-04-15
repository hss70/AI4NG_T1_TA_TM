import json
from typing import Any

import boto3


BUCKET = "ai4ng-eeg-results-047719656259-eu-west-2"
PREFIX = "benchmarks/"


def safe_get(data: dict[str, Any], path: list[str], default: Any = None) -> Any:
    current: Any = data
    for part in path:
        if not isinstance(current, dict) or part not in current:
            return default
        current = current[part]
    return current


def to_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def format_duration_from_ms(value: Any) -> str:
    ms = to_int(value, 0)
    if ms <= 0:
        return ""

    total_seconds = ms // 1000
    minutes = total_seconds // 60
    seconds = total_seconds % 60

    return f"{minutes}m {seconds:02d}s"


def list_benchmark_keys(s3_client: Any, bucket: str, prefix: str) -> list[str]:
    keys: list[str] = []
    paginator = s3_client.get_paginator("list_objects_v2")

    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            if not key.endswith(".json"):
                continue
            if key.endswith("manifest.json"):
                continue
            keys.append(key)

    return keys


def load_json(s3_client: Any, bucket: str, key: str) -> dict[str, Any]:
    response = s3_client.get_object(Bucket=bucket, Key=key)
    body = response["Body"].read().decode("utf-8")
    return json.loads(body)


def normalise_record(key: str, data: dict[str, Any]) -> dict[str, Any] | None:
    if "benchmarkId" not in data or "timingsMs" not in data:
        return None

    matlab_total_ms = safe_get(data, ["timingsMs", "matlabTotal"], "")

    record = {
        "benchmarkId": data.get("benchmarkId", ""),
        "label": data.get("label", ""),
        "status": data.get("status", ""),
        "workers": safe_get(data, ["config", "parallelWorkersRequested"], ""),
        "cpu": safe_get(data, ["config", "taskCpu"], ""),
        "memory": safe_get(data, ["config", "taskMemory"], ""),
        "availableCores": safe_get(data, ["config", "availableCores"], ""),
        "matlabTotalMs": matlab_total_ms,
        "matlabTotalMin": format_duration_from_ms(matlab_total_ms),
        "scriptTotalMs": safe_get(data, ["timingsMs", "scriptTotal"], ""),
        "exitCode": safe_get(data, ["execution", "exitCode"], ""),
        "failureReason": data.get("failureReason", ""),
        "key": key,
    }
    return record


def sort_records(records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    return sorted(
        records,
        key=lambda r: (
            str(r["benchmarkId"]),
            to_int(r["workers"], 999999),
            to_int(r["cpu"], 999999),
            to_int(r["memory"], 999999),
            str(r["label"]),
        ),
    )


def print_table(records: list[dict[str, Any]]) -> None:
    if not records:
        print("No benchmark records found.")
        return

    columns = [
        "benchmarkId",
        "label",
        "status",
        "workers",
        "cpu",
        "memory",
        "matlabTotalMs",
        "matlabTotalMin",
        "scriptTotalMs",
        "exitCode",
    ]

    widths: dict[str, int] = {}
    for col in columns:
        widths[col] = max(len(col), max(len(str(r.get(col, ""))) for r in records))

    header = " | ".join(col.ljust(widths[col]) for col in columns)
    divider = "-+-".join("-" * widths[col] for col in columns)

    print(header)
    print(divider)

    for record in records:
        print(
            " | ".join(
                str(record.get(col, "")).ljust(widths[col])
                for col in columns
            )
        )

    failures = [r for r in records if str(r.get("status", "")).upper() != "SUCCESS"]
    if failures:
        print("\nFailures:")
        for record in failures:
            print(
                f"- {record['label']} | exitCode={record['exitCode']} | "
                f"reason={record['failureReason'] or 'n/a'} | key={record['key']}"
            )


def print_best_per_worker_group(records: list[dict[str, Any]]) -> None:
    successful = [
        r for r in records
        if str(r.get("status", "")).upper() == "SUCCESS"
        and to_int(r.get("matlabTotalMs"), 0) > 0
    ]

    if not successful:
        print("\nNo successful runs found.")
        return

    best_by_workers: dict[str, dict[str, Any]] = {}
    for record in successful:
        workers = str(record["workers"])
        current_best = best_by_workers.get(workers)

        if (
            current_best is None or
            to_int(record["matlabTotalMs"], 10**12)
            < to_int(current_best["matlabTotalMs"], 10**12)
        ):
            best_by_workers[workers] = record

    sorted_records = [
        best_by_workers[w]
        for w in sorted(best_by_workers.keys(), key=lambda x: to_int(x, 999999))
    ]

    print("\nBest successful run per worker count:")
    print_table(sorted_records)


def print_fastest_runs(records: list[dict[str, Any]], top_n: int = 10) -> None:
    successful = [
        r for r in records
        if str(r.get("status", "")).upper() == "SUCCESS"
        and to_int(r.get("matlabTotalMs"), 0) > 0
    ]

    if not successful:
        print("\nNo successful runs found.")
        return

    successful.sort(key=lambda r: to_int(r.get("matlabTotalMs"), 10**12))

    top_runs = successful[:top_n]

    print(f"\nFastest successful runs by matlabTotalMs (top {len(top_runs)}):")
    print_table(top_runs)


def main() -> None:
    session = boto3.Session(profile_name="hardeepGmail")
    s3 = session.client("s3")

    print(f"Listing benchmark JSON files from s3://{BUCKET}/{PREFIX}")
    keys = list_benchmark_keys(s3, BUCKET, PREFIX)
    print(f"Found {len(keys)} JSON files\n")

    records: list[dict[str, Any]] = []
    skipped = 0

    for key in keys:
        try:
            data = load_json(s3, BUCKET, key)
            record = normalise_record(key, data)
            if record is None:
                skipped += 1
                continue
            records.append(record)
        except Exception as exc:
            print(f"Failed to read {key}: {exc}")

    records = sort_records(records)
    print_table(records)
    print_best_per_worker_group(records)
    print_fastest_runs(records)

    if skipped:
        print(f"\nSkipped {skipped} JSON files that did not look like benchmark summaries.")


if __name__ == "__main__":
    main()