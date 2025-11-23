import React, { useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { View, Text, TouchableOpacity, StyleSheet, Dimensions } from 'react-native';
import { useRouter } from 'expo-router';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';

const { width } = Dimensions.get('window');

const slides = [
    {
        id: 1,
        emoji: '🤝',
        title: 'Terhubung Kembali',
        description: 'Temukan teman lama seangkatan, bangun jejaring, dan pererat tali silaturahmi SMANSARA.',
    },
    {
        id: 2,
        emoji: '💼',
        title: 'Karir & Bisnis',
        description: 'Dapatkan info lowongan kerja eksklusif dan promosikan usaha Anda di marketplace alumni.',
    },
    {
        id: 3,
        emoji: '❤️',
        title: 'Kontribusi Sekolah',
        description: 'Ikut serta dalam memajukan almamater tercinta melalui donasi dan program mentoring.',
    },
];

export default function Onboarding() {
    const router = useRouter();
    const [currentSlide, setCurrentSlide] = useState(0);

    const completeOnboarding = async () => {
        try {
            await AsyncStorage.setItem('hasSeenOnboarding', 'true');
            router.replace('/(auth)/role-selection');
        } catch (e) {
            console.error('Failed to save onboarding status', e);
        }
    };

    const nextSlide = () => {
        if (currentSlide < slides.length - 1) {
            setCurrentSlide(currentSlide + 1);
        } else {
            completeOnboarding();
        }
    };

    const skip = () => {
        completeOnboarding();
    };

    return (
        <SafeAreaView style={styles.container}>
            <TouchableOpacity onPress={skip} style={styles.skipBtn}>
                <Text style={styles.skipText}>Lewati</Text>
            </TouchableOpacity>

            <View style={styles.slideContainer}>
                <Animated.View
                    key={slides[currentSlide].id}
                    entering={FadeIn.duration(500)}
                    exiting={FadeOut.duration(500)}
                    style={styles.slide}
                >
                    <View style={styles.illustration}>
                        <Text style={{ fontSize: 60 }}>{slides[currentSlide].emoji}</Text>
                    </View>
                    <View style={styles.contentText}>
                        <Text style={styles.title}>{slides[currentSlide].title}</Text>
                        <Text style={styles.description}>{slides[currentSlide].description}</Text>
                    </View>
                </Animated.View>
            </View>

            <View>
                <View style={styles.dotsContainer}>
                    {slides.map((_, index) => (
                        <View
                            key={index}
                            style={[
                                styles.dot,
                                currentSlide === index ? styles.dotActive : null
                            ]}
                        />
                    ))}
                </View>
                <TouchableOpacity style={styles.btnPrimary} onPress={nextSlide}>
                    <Text style={styles.btnText}>
                        {currentSlide === slides.length - 1 ? 'Mulai Sekarang' : 'Lanjut'}
                    </Text>
                </TouchableOpacity>
            </View>
        </SafeAreaView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        flexDirection: 'column',
        justifyContent: 'space-between',
        padding: 24,
        backgroundColor: 'white',
    },
    skipBtn: {
        alignSelf: 'flex-end',
    },
    skipText: {
        color: '#6B7280',
        fontWeight: '500',
        fontSize: 14,
    },
    slideContainer: {
        flex: 1,
        justifyContent: 'center',
    },
    slide: {
        alignItems: 'center',
    },
    illustration: {
        width: '100%',
        height: 250,
        backgroundColor: '#EEFBF6',
        borderRadius: 24,
        marginBottom: 30,
        alignItems: 'center',
        justifyContent: 'center',
    },
    contentText: {
        alignItems: 'center',
    },
    title: {
        fontSize: 24,
        color: '#006A4E',
        marginBottom: 12,
        fontWeight: 'bold',
        textAlign: 'center',
    },
    description: {
        color: '#6B7280',
        lineHeight: 24,
        fontSize: 15,
        textAlign: 'center',
    },
    dotsContainer: {
        flexDirection: 'row',
        justifyContent: 'center',
        gap: 8,
        marginBottom: 30,
    },
    dot: {
        width: 8,
        height: 8,
        borderRadius: 4,
        backgroundColor: '#E5E7EB',
    },
    dotActive: {
        backgroundColor: '#006A4E',
        width: 24,
        borderRadius: 10,
    },
    btnPrimary: {
        backgroundColor: '#006A4E',
        paddingVertical: 12,
        paddingHorizontal: 24,
        borderRadius: 8,
        alignItems: 'center',
    },
    btnText: {
        color: 'white',
        fontWeight: '600',
        fontSize: 16,
    },
});
