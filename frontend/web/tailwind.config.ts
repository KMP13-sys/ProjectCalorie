import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],

theme: {
  extend: {
    fontSize: {
      '8bit-sm': '40px',
      '8bit-base': '24px',
      '8bit-lg': '10px',
    },
    fontFamily: {
      ta8bit: ['TA8bit', 'sans-serif'],
    },
  },
}

};

export default config;