import { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator, StyleSheet } from 'react-native';
import { useRouter, Redirect } from 'expo-router';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useAuth } from '../context/AuthContext';
import { LinearGradient } from 'expo-linear-gradient';
import { GraduationCap } from 'lucide-react-native';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';

export default function Index() {
    const [isLoading, setIsLoading] = useState(true);
    const [hasSeenOnboarding, setHasSeenOnboarding] = useState(false);
    const { user, isLoading: isAuthLoading } = useAuth();
    const router = useRouter();

    useEffect(() => {
        checkOnboarding();
    }, []);

    const checkOnboarding = async () => {
        const start = Date.now();
        try {
            const value = await AsyncStorage.getItem('hasSeenOnboarding');
            if (value !== null) {
                setHasSeenOnboarding(true);
            }
        } catch (e) {
            console.error('Failed to fetch onboarding status', e);
        } finally {
            const elapsed = Date.now() - start;
            const delay = Math.max(0, 2000 - elapsed);
            setTimeout(() => {
                setIsLoading(false);
            }, delay);
        }
    };

    if (isLoading || isAuthLoading) {
        return (
            <LinearGradient
                colors={['#006A4E', '#004D38']}
                style={styles.container}
            >
                <Animated.View entering={FadeIn.duration(1000)} style={styles.content}>
                    <View style={styles.logoWrapper}>
                        <GraduationCap size={40} color="#006A4E" />
                    </View>
                    <Text style={styles.title}>IKA SMANSARA</Text>
                    <Text style={styles.subtitle}>Ikatan Alumni SMAN 1 Jepara</Text>

                    <View style={styles.loaderContainer}>
                        <ActivityIndicator size="large" color="#FFD700" />
                    </View>
                </Animated.View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>Ver 1.0.0 • Powered by Alumni</Text>
                </View>
            </LinearGradient>
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

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    content: {
        alignItems: 'center',
    },
    logoWrapper: {
        width: 100,
        height: 100,
        backgroundColor: 'white',
        borderRadius: 50,
        justifyContent: 'center',
        alignItems: 'center',
        marginBottom: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.2,
        shadowRadius: 10,
        elevation: 8,
    },
    title: {
        fontSize: 28,
        fontWeight: 'bold',
        color: 'white',
        letterSpacing: 1,
        marginBottom: 5,
    },
    subtitle: {
        fontSize: 14,
        color: 'rgba(255, 255, 255, 0.8)',
        marginBottom: 40,
    },
    loaderContainer: {
        marginTop: 20,
    },
    footer: {
        position: 'absolute',
        bottom: 40,
    },
    footerText: {
        color: 'rgba(255, 255, 255, 0.6)',
        fontSize: 12,
    },
});
