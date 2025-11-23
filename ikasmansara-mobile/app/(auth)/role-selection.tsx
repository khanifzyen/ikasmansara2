import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useRouter, Link } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import Animated, { FadeInDown } from 'react-native-reanimated';

export default function RoleSelection() {
    const router = useRouter();

    return (
        <SafeAreaView style={styles.container}>
            <View style={styles.content}>
                <View style={styles.header}>
                    <Text style={styles.title}>Siapa Anda?</Text>
                    <Text style={styles.subtitle}>Pilih peran untuk melanjutkan pendaftaran</Text>
                </View>

                <Animated.View entering={FadeInDown.delay(100).duration(500)}>
                    <TouchableOpacity
                        style={styles.card}
                        onPress={() => router.push('/(auth)/register-alumni')}
                    >
                        <View style={styles.iconContainer}>
                            <Text style={styles.icon}>🎓</Text>
                        </View>
                        <View style={styles.cardContent}>
                            <Text style={styles.cardTitle}>Saya Alumni</Text>
                            <Text style={styles.cardDesc}>Lulusan SMAN 1 Jepara. Memerlukan verifikasi angkatan.</Text>
                        </View>
                    </TouchableOpacity>
                </Animated.View>

                <Animated.View entering={FadeInDown.delay(200).duration(500)}>
                    <TouchableOpacity
                        style={styles.card}
                        onPress={() => router.push('/(auth)/register-public')}
                    >
                        <View style={styles.iconContainer}>
                            <Text style={styles.icon}>👤</Text>
                        </View>
                        <View style={styles.cardContent}>
                            <Text style={styles.cardTitle}>Umum / Staff</Text>
                            <Text style={styles.cardDesc}>Guru, Staff Sekolah, atau Masyarakat yang ingin berpartisipasi.</Text>
                        </View>
                    </TouchableOpacity>
                </Animated.View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>Sudah punya akun? </Text>
                    <Link href="/(auth)/login" asChild>
                        <TouchableOpacity>
                            <Text style={styles.link}>Masuk Disini</Text>
                        </TouchableOpacity>
                    </Link>
                </View>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#F9FAFB',
    },
    content: {
        flex: 1,
        padding: 24,
        justifyContent: 'center',
    },
    header: {
        marginBottom: 40,
        alignItems: 'center',
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        color: '#006A4E',
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 14,
        color: '#6B7280',
    },
    card: {
        backgroundColor: 'white',
        borderRadius: 16,
        padding: 24,
        marginBottom: 20,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 20,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.05,
        shadowRadius: 15,
        elevation: 2,
        borderWidth: 1,
        borderColor: '#F3F4F6',
    },
    iconContainer: {
        width: 50,
        height: 50,
        backgroundColor: '#EEFBF6',
        borderRadius: 12,
        alignItems: 'center',
        justifyContent: 'center',
    },
    icon: {
        fontSize: 24,
    },
    cardContent: {
        flex: 1,
    },
    cardTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: '#1F2937',
        marginBottom: 4,
    },
    cardDesc: {
        fontSize: 12,
        color: '#6B7280',
        lineHeight: 18,
    },
    footer: {
        marginTop: 40,
        flexDirection: 'row',
        justifyContent: 'center',
        alignItems: 'center',
    },
    footerText: {
        fontSize: 14,
        color: '#6B7280',
    },
    link: {
        fontSize: 14,
        fontWeight: '600',
        color: '#006A4E',
    },
});
