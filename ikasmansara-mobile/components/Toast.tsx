import React, { useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Platform } from 'react-native';
import Animated, { FadeInUp, FadeOutUp } from 'react-native-reanimated';
import { X, CheckCircle, AlertCircle, Info, AlertTriangle } from 'lucide-react-native';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

interface ToastProps {
    message: string;
    type: ToastType;
    onHide: () => void;
}

export const Toast = ({ message, type, onHide }: ToastProps) => {
    const getStyles = () => {
        switch (type) {
            case 'success':
                return { bg: '#ECFDF5', border: '#10B981', text: '#065F46', icon: '#10B981', Icon: CheckCircle };
            case 'error':
                return { bg: '#FEF2F2', border: '#EF4444', text: '#991B1B', icon: '#EF4444', Icon: AlertCircle };
            case 'warning':
                return { bg: '#FFFBEB', border: '#F59E0B', text: '#92400E', icon: '#F59E0B', Icon: AlertTriangle };
            case 'info':
            default:
                return { bg: '#EFF6FF', border: '#3B82F6', text: '#1E40AF', icon: '#3B82F6', Icon: Info };
        }
    };

    const style = getStyles();
    const Icon = style.Icon;

    useEffect(() => {
        const timer = setTimeout(() => {
            onHide();
        }, 3000);
        return () => clearTimeout(timer);
    }, [onHide]);

    return (
        <Animated.View
            entering={FadeInUp}
            exiting={FadeOutUp}
            style={[styles.container, { backgroundColor: style.bg, borderColor: style.border }]}
        >
            <Icon size={24} color={style.icon} />
            <Text style={[styles.message, { color: style.text }]}>{message}</Text>
            <TouchableOpacity onPress={onHide}>
                <X size={20} color={style.text} style={{ opacity: 0.6 }} />
            </TouchableOpacity>
        </Animated.View>
    );
};

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        top: Platform.OS === 'web' ? 20 : 60,
        left: 20,
        right: 20,
        padding: 16,
        borderRadius: 12,
        borderWidth: 1,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 8,
        elevation: 4,
        zIndex: 9999,
        maxWidth: 600,
        alignSelf: 'center',
        width: '90%',
    },
    message: {
        flex: 1,
        fontSize: 14,
        fontWeight: '500',
    },
});
