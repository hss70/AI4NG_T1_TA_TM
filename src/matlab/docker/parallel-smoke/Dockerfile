FROM containers.mathworks.com/matlab-runtime:r2024b

WORKDIR /app

COPY app/ /app/

RUN chmod +x /app/run_parallelSmoke.sh && \
    chmod +x /app/parallelSmoke

ENV MCR_CACHE_ROOT=/tmp/mcr-cache
ENV MATLAB_PREFDIR=/tmp/matlab-prefs
ENV AGREE_TO_MATLAB_RUNTIME_LICENSE=yes

ENTRYPOINT ["/app/run_parallelSmoke.sh", "/opt/matlabruntime/R2024b"]