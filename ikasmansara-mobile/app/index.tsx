import { useEffect, useState } from 'react';
import { View, ActivityIndicator } from 'react-native';
import { useRouter, Redirect } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuth } from '../context/AuthContext';

export default function Index() {
    const [isLoading, setIsLoading] = useState(true);
    const [hasSeenOnboarding, setHasSeenOnboarding] = useState(false);
    const { user, isLoading: isAuthLoading } = useAuth();
    const router = useRouter();

    useEffect(() => {
        checkOnboarding();
    }, []);

    const checkOnboarding = async () => {
        try {
            const value = await AsyncStorage.getItem('hasSeenOnboarding');
            if (value !== null) {
                setHasSeenOnboarding(true);
            }
        } catch (e) {
            console.error('Failed to fetch onboarding status', e);
        } finally {
            setIsLoading(false);
        }
    };

    if (isLoading || isAuthLoading) {
        return (
            <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
                <ActivityIndicator size="large" color="#006A4E" />
            </View>
        );
    }

    if (user) {
        return <Redirect href="/(app)/home" />;
    }

    if (!hasSeenOnboarding) {
        return <Redirect href="/onboarding" />;
    }

    return <Redirect href="/(auth)/role-selection" />;
}
