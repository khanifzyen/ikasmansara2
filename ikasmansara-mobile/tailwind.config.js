/** @type {import('tailwindcss').Config} */
module.exports = {
    content: ["./app/**/*.{js,jsx,ts,tsx}", "./components/**/*.{js,jsx,ts,tsx}"],
    presets: [require("nativewind/preset")],
    theme: {
        extend: {
            colors: {
                primary: '#006A4E',
                'primary-dark': '#004D38',
                secondary: '#FFD700',
                'text-grey': '#6B7280',
            }
        },
    },
    plugins: [],
}
