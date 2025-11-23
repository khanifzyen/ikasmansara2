import React, { createContext, useContext, useEffect, useState } from 'react';
import pb from '../lib/pocketbase';
import { AuthModel } from 'pocketbase';

interface AuthContextType {
    user: AuthModel | null;
    isLoading: boolean;
    login: () => void; // Refreshes state
    logout: () => void;
}

const AuthContext = createContext<AuthContextType>({
    user: null,
    isLoading: true,
    login: () => { },
    logout: () => { },
});

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
    const [user, setUser] = useState<AuthModel | null>(pb.authStore.model);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Check initial auth state
        const checkAuth = async () => {
            try {
                // Validate current token if it exists
                if (pb.authStore.isValid) {
                    await pb.collection('users').authRefresh();
                }
            } catch (error) {
                console.log('Auth refresh failed', error);
                pb.authStore.clear();
            } finally {
                setUser(pb.authStore.model);
                setIsLoading(false);
            }
        };

        checkAuth();

        // Subscribe to auth changes
        const unsubscribe = pb.authStore.onChange((token, model) => {
            setUser(model);
        });

        return () => {
            unsubscribe();
        };
    }, []);

    const login = () => {
        setUser(pb.authStore.model);
    };

    const logout = () => {
        pb.authStore.clear();
    };

    return (
        <AuthContext.Provider value={{ user, isLoading, login, logout }}>
            {children}
        </AuthContext.Provider>
    );
};
