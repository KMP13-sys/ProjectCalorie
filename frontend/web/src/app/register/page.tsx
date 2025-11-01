'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { authAPI, RegisterData } from '@/services/auth_service';

export default function RegisterPage() {
  const router = useRouter();
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    age: '',
    gender: '',
    height: '',
    weight: '',
    goal: '',
    agreedToTerms: false
  });

  const [showPrivacyModal, setShowPrivacyModal] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value, type } = e.target;
    const checked = (e.target as HTMLInputElement).checked;
    
    // Validate username real-time
    if (name === 'username') {
      // อนุญาตแค่ a-z, A-Z, 0-9
      const sanitized = value.replace(/[^a-zA-Z0-9]/g, '');
      setFormData(prev => ({
        ...prev,
        [name]: sanitized
      }));
    } 
    // Validate email real-time (ลบช่องว่าง)
    else if (name === 'email') {
      const sanitized = value.replace(/\s/g, ''); // ลบช่องว่างทั้งหมด
      setFormData(prev => ({
        ...prev,
        [name]: sanitized
      }));
    } 
    else {
      setFormData(prev => ({
        ...prev,
        [name]: type === 'checkbox' ? checked : value
      }));
    }
    
    // Clear error when user types
    if (error) setError('');
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // Username validation
    const username = formData.username.trim();

    if (!/[a-zA-Z]/.test(username)) {
      setError('Username ต้องมีตัวอักษร (a-z หรือ A-Z) อย่างน้อย 1 ตัว');
      return;
    }

    if (username.length < 3) {
      setError('Username ต้องมีอย่างน้อย 3 ตัวอักษร');
      return;
    }

    // Email validation
    const email = formData.email.trim();
    
    if (!email) {
      setError('กรุณากรอกอีเมล');
      return;
    }

    // ตรวจสอบรูปแบบอีเมลด้วย Regular Expression
    const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    if (!emailRegex.test(email)) {
      setError('รูปแบบอีเมลไม่ถูกต้อง (ตัวอย่าง: example@email.com)');
      return;
    }

    // ตรวจสอบว่าไม่มีช่องว่างในอีเมล
    if (email.includes(' ')) {
      setError('อีเมลต้องไม่มีช่องว่าง');
      return;
    }

    // Phone validation (ต้องเป็นตัวเลข 0-9 และ 10 หลัก)
    if (!/^[0-9]{10}$/.test(formData.phone.trim())) {
      setError('กรุณากรอกหมายเลขโทรศัพท์ 10 หลัก');
      return;
    }

    // Validation password
    if (formData.password !== formData.confirmPassword) {
      setError('Password ไม่ตรงกัน!');
      return;
    }

    // Password validation (ตรงกับ Backend: ต้องมีตัวอักษร + อักขระพิเศษ + ความยาว 8+)
    const passwordRegex = /^(?=.*[A-Za-z])(?=.*[\W_]).{8,}$/;
    if (!passwordRegex.test(formData.password)) {
      setError('Password ต้องมีอย่างน้อย 8 ตัวอักษร และมีทั้งตัวอักษรและอักขระพิเศษ');
      return;
    }

    // Validate numbers
    const age = parseInt(formData.age);
    const height = parseFloat(formData.height);
    const weight = parseFloat(formData.weight);

    if (isNaN(age) || age < 13 || age > 120) {
      setError('ต้องมีอายุอย่างน้อย 13 ปีขึ้นไป');
      return;
    }

    if (isNaN(height) || height < 100 || height > 250) {
      setError('กรุณากรอกส่วนสูงที่ถูกต้อง');
      return;
    }

    if (isNaN(weight) || weight < 30 || weight > 300) {
      setError('กรุณากรอกน้ำหนักที่ถูกต้อง');
      return;
    }

    if (!formData.agreedToTerms) {
      setError('กรุณายอมรับข้อกำหนดและเงื่อนไข');
      return;
    }

    setIsLoading(true);

    try {
      // เตรียมข้อมูลสำหรับส่ง API
      const registerData: RegisterData = {
        username: formData.username.trim(),
        email: formData.email.trim(),
        phone_number: formData.phone.trim(),
        password: formData.password,
        age: age,
        gender: formData.gender,
        height: height,
        weight: weight,
        goal: formData.goal,
      };

      // เรียก API
      const response = await authAPI.register(registerData);
      
      console.log('Register success:', response);
      
      // แสดง Success Modal
      setShowSuccessModal(true);
      
    } catch (err: any) {
      console.error('Register error:', err);
      setError(err.message || 'เกิดข้อผิดพลาดในการสมัครสมาชิก');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSuccessModalClose = () => {
    setShowSuccessModal(false);
    router.push('/login');
  };

  const handleNavigateToLogin = () => {
    router.push('/login');
  };

  return (
    <>
      <div className="min-h-screen bg-gradient-to-br from-[#6fa85e] via-[#8bc273] to-[#a8d48f] flex items-center justify-center p-8 relative overflow-hidden">
        {/* Pixel Grid Background Pattern */}
        <div 
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage: `
              linear-gradient(0deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent),
              linear-gradient(90deg, transparent 24%, rgba(255, 255, 255, .3) 25%, rgba(255, 255, 255, .3) 26%, transparent 27%, transparent 74%, rgba(255, 255, 255, .3) 75%, rgba(255, 255, 255, .3) 76%, transparent 77%, transparent)
            `,
            backgroundSize: '50px 50px'
          }}
        ></div>

        {/* Floating Pixel Decorations */}
        <div className="absolute top-10 left-10 w-6 h-6 bg-yellow-300 animate-bounce"></div>
        <div className="absolute top-20 right-16 w-4 h-4 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.3s' }}></div>
        <div className="absolute bottom-20 left-20 w-5 h-5 bg-yellow-300 animate-bounce" style={{ animationDelay: '0.6s' }}></div>

        <div className="relative z-10 w-full max-w-2xl">
          <div 
            className="bg-white border-8 border-black relative"
            style={{ 
              boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute top-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-6 h-6 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-6 h-6 bg-[#6fa85e]"></div>

            {/* Header Bar */}
            <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black py-3 px-6">
              <h2 
                className="text-2xl font-bold text-white text-center tracking-wider"
                style={{ 
                  fontFamily: 'TA8bit',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.3)'
                }}
              >
                ◆ CREATE ACCOUNT ◆
              </h2>
            </div>

            <div className="p-8">
              {/* Logo */}
              <div className="flex flex-col items-center mb-6">
                <div 
                  className="bg-gradient-to-br from-[#a8d48f] to-[#8bc273] border-4 border-black p-3 mb-3"
                  style={{ boxShadow: '4px 4px 0px rgba(0,0,0,0.2)' }}
                >
                  <img
                    src="/pic/logo.png"
                    alt="Logo"
                    className="w-32 h-32 object-contain"
                    style={{ imageRendering: 'pixelated' }}
                  />
                </div>
                <p 
                  className="text-xl font-bold text-gray-800 tracking-wider"
                  style={{ fontFamily: 'TA8bit' }}
                >
                  CAL-DEFICITS
                </p>
                <div className="flex gap-1 mt-2">
                  <div className="w-2 h-2 bg-[#6fa85e]"></div>
                  <div className="w-2 h-2 bg-[#8bc273]"></div>
                  <div className="w-2 h-2 bg-[#a8d48f]"></div>
                </div>
              </div>

              {/* Error Message */}
              {error && (
                <div 
                  className="mb-4 p-3 bg-red-200 border-4 border-red-600 text-red-800"
                  style={{ fontFamily: 'TA8bit' }}
                >
                  <div className="flex items-center gap-2">
                    <span className="text-xl">⚠</span>
                    <span className="text-sm font-bold">{error}</span>
                  </div>
                </div>
              )}

              {/* Register Form */}
              <form onSubmit={handleRegister} className="space-y-4">
                {/* Account Information Section */}
                <div className="bg-gray-100 border-4 border-gray-800 p-4 mb-4">
                  <h3 
                    className="text-lg font-bold text-gray-800 mb-3"
                    style={{ fontFamily: 'TA8bit' }}
                  >
                    ▶ ACCOUNT INFO
                  </h3>

                  <div className="space-y-3">
                    <div>
                      <label 
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        USERNAME *
                      </label>
                      <input
                        type="text"
                        name="username"
                        placeholder="Enter username..."
                        value={formData.username}
                        onChange={handleChange}
                        required
                        minLength={3}
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      />
                    </div>

                    <div>
                      <label 
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        EMAIL *
                      </label>
                      <input
                        type="email"
                        name="email"
                        placeholder="Enter email..."
                        value={formData.email}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      />
                    </div>

                    <div>
                      <label 
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        PHONE *
                      </label>
                      <input
                        type="tel"
                        name="phone"
                        placeholder="Enter phone..."
                        value={formData.phone}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      />
                    </div>

                    <div>
                      <label
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        PASSWORD * (8+ chars, letter + special)
                      </label>
                      <input
                        type="password"
                        name="password"
                        placeholder="e.g. Pass@123"
                        value={formData.password}
                        onChange={handleChange}
                        required
                        minLength={8}
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      />
                    </div>

                    <div>
                      <label 
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        CONFIRM PASSWORD *
                      </label>
                      <input
                        type="password"
                        name="confirmPassword"
                        placeholder="Re-enter password..."
                        value={formData.confirmPassword}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      />
                    </div>
                  </div>
                </div>

                {/* Personal Information Section */}
                <div className="bg-gray-100 border-4 border-gray-800 p-4">
                  <h3 
                    className="text-lg font-bold text-gray-800 mb-3"
                    style={{ fontFamily: 'TA8bit' }}
                  >
                    ▶ PERSONAL INFO
                  </h3>

                  <div className="space-y-3">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label 
                          className="block text-xs font-bold text-gray-700 mb-1"
                          style={{ fontFamily: 'TA8bit' }}
                        >
                          AGE *
                        </label>
                        <input
                          type="number"
                          name="age"
                          placeholder="Years"
                          value={formData.age}
                          onChange={handleChange}
                          required
                          min="13"
                          max="120"
                          className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                          style={{ fontFamily: 'TA8bit' }}
                        />
                      </div>

                      <div>
                        <label 
                          className="block text-xs font-bold text-gray-700 mb-1"
                          style={{ fontFamily: 'TA8bit' }}
                        >
                          GENDER *
                        </label>
                        <select
                          name="gender"
                          value={formData.gender}
                          onChange={handleChange}
                          required
                          className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                          style={{ fontFamily: 'TA8bit' }}
                        >
                          <option value="">Select...</option>
                          <option value="male">MALE</option>
                          <option value="female">FEMALE</option>
                        </select>
                      </div>
                    </div>

                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label 
                          className="block text-xs font-bold text-gray-700 mb-1"
                          style={{ fontFamily: 'TA8bit' }}
                        >
                          HEIGHT *
                        </label>
                        <input
                          type="number"
                          name="height"
                          placeholder="(CM)"
                          value={formData.height}
                          onChange={handleChange}
                          required
                          min="100"
                          max="250"
                          step="0.1"
                          className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                          style={{ fontFamily: 'TA8bit' }}
                        />
                      </div>

                      <div>
                        <label 
                          className="block text-xs font-bold text-gray-700 mb-1"
                          style={{ fontFamily: 'TA8bit' }}
                        >
                          WEIGHT *
                        </label>
                        <input
                          type="number"
                          name="weight"
                          placeholder="(KG)"
                          value={formData.weight}
                          onChange={handleChange}
                          required
                          min="30"
                          max="300"
                          step="0.1"
                          className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 placeholder-gray-500 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                          style={{ fontFamily: 'TA8bit' }}
                        />
                      </div>
                    </div>

                    <div>
                      <label 
                        className="block text-xs font-bold text-gray-700 mb-1"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        GOAL *
                      </label>
                      <select
                        name="goal"
                        value={formData.goal}
                        onChange={handleChange}
                        required
                        className="w-full px-3 py-2 bg-white border-3 border-gray-800 text-gray-800 focus:outline-none focus:border-[#6fa85e] font-mono text-sm"
                        style={{ fontFamily: 'TA8bit' }}
                      >
                        <option value="">Select goal...</option>
                        <option value="lose weight">LOSE WEIGHT</option>
                        <option value="maintain weight">MAINTAIN WEIGH</option>
                        <option value="gain weight">GAIN WEIGHT</option>
                      </select>
                    </div>
                  </div>
                </div>

                {/* Terms and Conditions */}
                <div className="flex items-start gap-2 mt-4 bg-gray-100 border-4 border-gray-800 p-3">
                  <input
                    type="checkbox"
                    name="agreedToTerms"
                    id="terms"
                    checked={formData.agreedToTerms}
                    onChange={handleChange}
                    required
                    className="mt-1 w-4 h-4"
                  />
                  <label 
                    htmlFor="terms" 
                    className="text-xs text-gray-700 font-bold"
                    style={{ fontFamily: 'TA8bit' }}
                  >
                    I ACCEPT TERMS AND{' '}
                    <button
                      type="button"
                      onClick={() => setShowPrivacyModal(true)}
                      className="text-[#6fa85e] underline hover:text-[#8bc273]"
                    >
                      PRIVACY POLICY
                    </button>
                  </label>
                </div>

                {/* Register Button */}
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-4 bg-gradient-to-r from-[#6fa85e] to-[#8bc273] hover:from-[#8bc273] hover:to-[#a8d48f] border-4 border-black text-white font-bold transition-all disabled:opacity-50 disabled:cursor-not-allowed mt-6"
                  style={{ 
                    fontFamily: 'TA8bit',
                    boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
                    textShadow: '2px 2px 0px rgba(0,0,0,0.5)',
                    fontSize: '18px'
                  }}
                >
                  {isLoading ? '▶ CREATING...' : '▶ CREATE ACCOUNT'}
                </button>
              </form>

              {/* Link to Login - แสดงเสมอ */}
              <div className="mt-6 pt-6 border-t-4 border-dashed border-gray-300 text-center">
                <button
                  type="button"
                  onClick={handleNavigateToLogin}
                  className="px-6 py-2 bg-gray-800 hover:bg-gray-700 border-3 border-black text-white text-sm font-bold transition-all"
                  style={{ 
                    fontFamily: 'TA8bit',
                    boxShadow: '3px 3px 0px rgba(0,0,0,0.3)'
                  }}
                >
                  ← BACK TO LOGIN
                </button>
              </div>
            </div>
          </div>

          {/* Pixel "Info" hint */}
          <div className="text-center mt-6">
            <p 
              className="text-white text-sm font-bold animate-pulse"
              style={{ 
                fontFamily: 'TA8bit',
                textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
              }}
            >
              ▼ FILL IN YOUR DATA ▼
            </p>
          </div>
        </div>
      </div>

      {/* Success Modal - เหมือนเดิม */}
      {showSuccessModal && (
        <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
          <div 
            className="bg-gradient-to-b from-[#a8d48f] to-[#8bc273] border-8 border-black w-full max-w-md relative"
            style={{ 
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <div className="absolute top-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>

            <div className="p-8 text-center relative">
              <div className="bg-[#6fa85e] border-b-4 border-black -mx-8 -mt-8 mb-6 py-3">
                <h3 className="text-2xl font-bold text-white tracking-wider" style={{ textShadow: '3px 3px 0px rgba(0,0,0,0.3)', fontFamily: 'TA8bit' }}>
                  ★ ACCOUNT CREATED! ★
                </h3>
              </div>

              <div className="flex justify-center mb-4">
                <div className="relative w-16 h-16">
                  <div className="grid grid-cols-5 gap-0">
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-yellow-300"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-yellow-300"></div>
                    <div className="w-3 h-3 bg-yellow-200"></div>
                    <div className="w-3 h-3 bg-yellow-300"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-yellow-300"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-yellow-400"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                    <div className="w-3 h-3 bg-transparent"></div>
                  </div>
                </div>
              </div>

              <div className="bg-white border-4 border-black p-4 mb-6">
                <p className="text-xl font-bold text-gray-800 mb-2" style={{ fontFamily: 'TA8bit' }}>
                  ACCOUNT CREATED!
                </p>
                <p className="text-sm text-gray-600" style={{ fontFamily: 'TA8bit' }}>
                  Welcome to CAL-DEFICITS!
                </p>
              </div>

              <button
                onClick={handleSuccessModalClose}
                className="w-full py-3 bg-gradient-to-r from-[#6fa85e] to-[#8bc273] hover:from-[#8bc273] hover:to-[#a8d48f] border-4 border-black text-white font-bold transition-all"
                style={{ 
                  fontFamily: 'TA8bit',
                  boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                  textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
                }}
              >
                ▶ CONTINUE
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Privacy Policy Modal - ไม่แก้ไข ยาวมาก ตัดออก */}
      {showPrivacyModal && (
        <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
          <div 
            className="bg-white border-8 border-black w-full max-w-2xl max-h-[90vh] flex flex-col relative"
            style={{ 
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            <div className="absolute top-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>

            <div className="bg-gradient-to-r from-[#6fa85e] to-[#8bc273] border-b-6 border-black py-4 px-6 flex items-center justify-between">
              <h2 
                className="text-2xl font-bold text-white tracking-wider"
                style={{ 
                  fontFamily: 'TA8bit',
                  textShadow: '3px 3px 0px rgba(0,0,0,0.3)'
                }}
              >
                PRIVACY POLICY
              </h2>
              <button
                onClick={() => setShowPrivacyModal(false)}
                className="text-white hover:text-gray-200 text-4xl leading-none font-bold"
                style={{ fontFamily: 'TA8bit' }}
              >
                ×
              </button>
            </div>

            <div className="p-6 overflow-y-auto flex-1">
              <div className="space-y-4 text-gray-700" style={{ fontFamily: 'TA8bit', fontSize: '13px' }}>
                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    1. ข้อมูลที่เราเก็บรวบรวม
                  </h3>
                  <p className="text-sm leading-relaxed">
                    CAL-DEFICITS เก็บรวบรวมข้อมูลส่วนบุคคลของคุณ เช่น ชื่อผู้ใช้ อีเมล หมายเลขโทรศัพท์ 
                    และข้อมูลสุขภาพที่เกี่ยวข้องกับการคำนวณแคลอรี่ เพื่อใช้ในการให้บริการและปรับปรุงประสบการณ์การใช้งาน
                  </p>
                </section>

                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    2. การใช้ข้อมูล
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราใช้ข้อมูลของคุณเพื่อ:
                  </p>
                  <ul className="list-disc list-inside text-sm space-y-1 ml-4 mt-2">
                    <li>ให้บริการคำนวณและติดตามแคลอรี่</li>
                    <li>สร้างและจัดการบัญชีผู้ใช้งาน</li>
                    <li>ปรับปรุงและพัฒนาบริการของเรา</li>
                    <li>ส่งการแจ้งเตือนและข้อมูลที่เกี่ยวข้อง</li>
                  </ul>
                </section>

                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    3. การปกป้องข้อมูล
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลส่วนบุคคลของคุณจากการเข้าถึงการใช้ 
                    หรือการเปิดเผยโดยไม่ได้รับอนุญาต ข้อมูลทั้งหมดจะถูกเข้ารหัสและจัดเก็บอย่างปลอดภัย
                  </p>
                </section>

                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    4. การแบ่งปันข้อมูล
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราจะไม่ขาย เช่า หรือแบ่งปันข้อมูลส่วนบุคคลของคุณให้กับบุคคลที่สาม 
                    ยกเว้นในกรณีที่จำเป็นตามกฎหมายหรือได้รับความยินยอมจากคุณ
                  </p>
                </section>

                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    5. สิทธิของผู้ใช้งาน
                  </h3>
                  <p className="text-sm leading-relaxed">
                    คุณมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณได้ตลอดเวลา 
                    สามารถติดต่อเราได้ผ่านทางอีเมล หรือในส่วนการตั้งค่าบัญชี
                  </p>
                </section>

                <section>
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    6. การเปลี่ยนแปลงนโยบาย
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราอาจปรับปรุงนโยบายความเป็นส่วนตัวนี้เป็นครั้งคราว 
                    การเปลี่ยนแปลงจะมีผลทันทีเมื่อเผยแพร่บนเว็บไซต์
                  </p>
                </section>

                <section className="pt-4 border-t-4 border-dashed border-gray-300">
                  <h3 className="text-base font-bold text-gray-800 mb-2">
                    ติดต่อเรา
                  </h3>
                  <p className="text-sm leading-relaxed">
                    หากคุณมีคำถามเกี่ยวกับนโยบายความเป็นส่วนตัว กรุณาติดต่อเราที่:
                  </p>
                  <p className="text-sm mt-2">
                    <strong>Email:</strong> support@cal-deficits.com<br />
                    <strong>วันที่มีผลบังคับใช้:</strong> 12 ตุลาคม 2025
                  </p>
                </section>
              </div>
            </div>

            <div className="p-6 border-t-6 border-black">
              <button
                onClick={() => setShowPrivacyModal(false)}
                className="w-full py-3 bg-gradient-to-r from-[#6fa85e] to-[#8bc273] hover:from-[#8bc273] hover:to-[#a8d48f] border-4 border-black text-white font-bold transition-all"
                style={{ 
                  fontFamily: 'TA8bit',
                  boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                  textShadow: '2px 2px 0px rgba(0,0,0,0.5)'
                }}
              >
                ◀ CLOSE
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}