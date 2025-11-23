import PocketBase, { AsyncAuthStore } from 'pocketbase';
import AsyncStorage from '@react-native-async-storage/async-storage';

const store = new AsyncAuthStore({
    save: async (serialized) => {
        try {
            await AsyncStorage.setItem('pb_auth', serialized);
        } catch (e) {
            console.error('PocketBase auth save failed:', e);
        }
    },
    initial: AsyncStorage.getItem('pb_auth'),
    clear: async () => {
        try {
            await AsyncStorage.removeItem('pb_auth');
        } catch (e) {
            console.error('PocketBase auth clear failed:', e);
        }
    }
});

const pb = new PocketBase(process.env.EXPO_PUBLIC_POCKETBASE_URL, store);

export default pb;
