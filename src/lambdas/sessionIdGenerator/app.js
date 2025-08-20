exports.handler = async (event) => {
    const { userId, sessionName } = event;
    
    if (!userId || !sessionName) {
        throw new Error('userId and sessionName are required');
    }
    
    // JavaScript implementation of the C# hash function
    const combined = userId + sessionName;
    let hash = 0;
    
    for (let i = 0; i < combined.length; i++) {
        const char = combined.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32-bit integer
    }
    
    return {
        sessionId: Math.abs(hash),
        userId,
        sessionName
    };
};