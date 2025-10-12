'use client';

import { useState } from 'react';
import { authAPI, RegisterData } from '@/app/pages/api';

interface RegisterPageProps {
  onNavigateToLogin?: () => void;
}

export default function RegisterPage({ onNavigateToLogin }: RegisterPageProps) {
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    phone: '',
    password: '',
    confirmPassword: '',
    agreedToTerms: false
  });

  const [showPrivacyModal, setShowPrivacyModal] = useState(false);
  const [showSuccessModal, setShowSuccessModal] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
    
    // Clear error when user types
    if (error) setError('');
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    
    // Validation
    if (formData.password !== formData.confirmPassword) {
      setError('Password ไม่ตรงกัน!');
      return;
    }
    
    if (formData.password.length < 6) {
      setError('Password ต้องมีอย่างน้อย 6 ตัวอักษร');
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

    // Redirect ไปหน้า login (ใช้ path ที่ถูกต้อง)
    window.location.href = '/Authen/login';
  };

  return (
    <>
      <div className="min-h-screen bg-[#DBFFC8] flex items-center justify-center p-4">
        <div className="bg-white border-3 border-black p-12 w-full max-w-md">
          {/* Logo */}
          <div className="flex flex-col items-center mb-8">
            <img 
              src="/pic/logoja.png"
              alt="Logo"
              className="w-48 h-48 object-contain mb-4"
            />
            <h1 className="text-2xl font-bold text-gray-800 tracking-wider">
              CAL-DEFICITS
            </h1>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mb-4 p-3 bg-red-100 border border-red-400 text-red-700 rounded text-sm">
              {error}
            </div>
          )}

          {/* Register Form */}
          <form onSubmit={handleRegister} className="space-y-4">
            <input
              type="text"
              name="username"
              placeholder="Username"
              value={formData.username}
              onChange={handleChange}
              required
              minLength={3}
              className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
            />
            
            <input
              type="email"
              name="email"
              placeholder="Email"
              value={formData.email}
              onChange={handleChange}
              required
              className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
            />

            <input
              type="tel"
              name="phone"
              placeholder="Phone No *"
              value={formData.phone}
              onChange={handleChange}
              required
              className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
            />
            
            <input
              type="password"
              name="password"
              placeholder="Password"
              value={formData.password}
              onChange={handleChange}
              required
              minLength={6}
              className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
            />

            <input
              type="password"
              name="confirmPassword"
              placeholder="Confirm password"
              value={formData.confirmPassword}
              onChange={handleChange}
              required
              className="w-full px-4 py-3 bg-gray-200 text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-gray-400"
            />

            {/* Terms and Conditions */}
            <div className="flex items-start gap-2 mt-4">
              <input
                type="checkbox"
                name="agreedToTerms"
                id="terms"
                checked={formData.agreedToTerms}
                onChange={handleChange}
                required
                className="mt-1 w-4 h-4"
              />
              <label htmlFor="terms" className="text-sm text-gray-600">
                I accept term and condition and{' '}
                <button
                  type="button"
                  onClick={() => setShowPrivacyModal(true)}
                  className="text-blue-600 underline hover:text-blue-800"
                >
                  privacy policy
                </button>
              </label>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full py-3 bg-[#8b9d6f] text-white font-semibold hover:bg-[#7a8c5e] transition-colors border-2 border-black mt-6 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? 'กำลังสมัครสมาชิก...' : 'REGISTER'}
            </button>
          </form>

          {/* Link to Login */}
          {onNavigateToLogin && (
            <div className="mt-4 text-center">
              <button
                type="button"
                onClick={onNavigateToLogin}
                className="text-sm text-gray-600 hover:underline"
              >
                มีบัญชีอยู่แล้ว? เข้าสู่ระบบ
              </button>
            </div>
          )}
        </div>
      </div>

      {/* Success Modal */}
      {showSuccessModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-2xl w-full max-w-md">
            <div className="p-8 text-center">
              {/* Success Icon */}
              <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-green-100 mb-4">
                <svg
                  className="h-10 w-10 text-green-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M5 13l4 4L19 7"
                  />
                </svg>
              </div>

              {/* Success Message */}
              <h3 className="text-2xl font-bold text-gray-800 mb-2">
                สมัครสมาชิกสำเร็จ!
              </h3>
              <p className="text-gray-600 mb-6">
                ยินดีต้อนรับเข้าสู่ CAL-DEFICITS<br />
                กรุณาเข้าสู่ระบบเพื่อใช้งาน
              </p>

              {/* OK Button */}
              <button
                onClick={handleSuccessModalClose}
                className="w-full py-3 bg-[#8b9d6f] text-white font-semibold hover:bg-[#7a8c5e] transition-colors rounded border-2 border-black"
              >
                ตกลง
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Privacy Policy Modal */}
      {showPrivacyModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg shadow-2xl w-full max-w-2xl max-h-[90vh] flex flex-col">
            {/* Modal Header */}
            <div className="flex items-center justify-between p-6 border-b border-gray-200">
              <h2 className="text-2xl font-bold text-gray-800">Privacy Policy</h2>
              <button
                onClick={() => setShowPrivacyModal(false)}
                className="text-gray-500 hover:text-gray-700 text-3xl leading-none"
              >
                ×
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6 overflow-y-auto flex-1">
              <div className="space-y-4 text-gray-700">
                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    1. ข้อมูลที่เราเก็บรวบรวม
                  </h3>
                  <p className="text-sm leading-relaxed">
                    CAL-DEFICITS เก็บรวบรวมข้อมูลส่วนบุคคลของคุณ เช่น ชื่อผู้ใช้ อีเมล หมายเลขโทรศัพท์ 
                    และข้อมูลสุขภาพที่เกี่ยวข้องกับการคำนวณแคลอรี่ เพื่อใช้ในการให้บริการและปรับปรุงประสบการณ์การใช้งาน
                  </p>
                </section>

                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
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
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    3. การปกป้องข้อมูล
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อปกป้องข้อมูลส่วนบุคคลของคุณจากการเข้าถึง 
                    การใช้ หรือการเปิดเผยโดยไม่ได้รับอนุญาต ข้อมูลทั้งหมดจะถูกเข้ารหัสและจัดเก็บอย่างปลอดภัย
                  </p>
                </section>

                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    4. การแบ่งปันข้อมูล
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราจะไม่ขาย เช่า หรือแบ่งปันข้อมูลส่วนบุคคลของคุณให้กับบุคคลที่สาม 
                    ยกเว้นในกรณีที่จำเป็นตามกฎหมายหรือได้รับความยินยอมจากคุณ
                  </p>
                </section>

                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    5. สิทธิของผู้ใช้งาน
                  </h3>
                  <p className="text-sm leading-relaxed">
                    คุณมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของคุณได้ตลอดเวลา 
                    สามารถติดต่อเราได้ผ่านทางอีเมล หรือในส่วนการตั้งค่าบัญชี
                  </p>
                </section>

                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    6. คุกกี้และเทคโนโลยีติดตาม
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เว็บไซต์ของเราอาจใช้คุกกี้เพื่อปรับปรุงประสบการณ์การใช้งาน 
                    คุณสามารถตั้งค่าเบราว์เซอร์เพื่อปฏิเสธคุกกี้ได้ แต่อาจส่งผลต่อการใช้งานบางฟีเจอร์
                  </p>
                </section>

                <section>
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
                    7. การเปลี่ยนแปลงนโยบาย
                  </h3>
                  <p className="text-sm leading-relaxed">
                    เราอาจปรับปรุงนโยบายความเป็นส่วนตัวนี้เป็นครั้งคราว 
                    การเปลี่ยนแปลงจะมีผลทันทีเมื่อเผยแพร่บนเว็บไซต์
                  </p>
                </section>

                <section className="pt-4 border-t border-gray-200">
                  <h3 className="text-lg font-semibold text-gray-800 mb-2">
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

            {/* Modal Footer */}
            <div className="p-6 border-t border-gray-200">
              <button
                onClick={() => setShowPrivacyModal(false)}
                className="w-full py-3 bg-[#8b9d6f] text-white font-semibold hover:bg-[#7a8c5e] transition-colors rounded"
              >
                ปิด
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}