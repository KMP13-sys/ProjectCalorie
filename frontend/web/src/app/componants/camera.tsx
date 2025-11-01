'use client';

import { useState, useRef } from 'react';
import Image from 'next/image';
import { useRouter } from 'next/navigation';
import { predictFood } from '../../services/predict_service';

interface ImageUploadButtonProps {
  onImageSelect?: (file: File | null) => void;
  buttonText?: string;
  maxSize?: number;
  showPreview?: boolean;
  autoPredictOnSelect?: boolean;
}

/**
 * Image Upload Button Component
 * อัปโหลดรูปอาหารเพื่อใช้ AI วิเคราะห์และคำนวณค่าโภชนาการ
 * รองรับการ predict อัตโนมัติเมื่อเลือกรูป
 */
export default function ImageUploadButton({
  onImageSelect,
  buttonText = 'แนบรูปอาหาร',
  maxSize = 5,
  showPreview = false,
  autoPredictOnSelect = false
}: ImageUploadButtonProps) {
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState<boolean>(false);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const router = useRouter();

  const handleButtonClick = () => {
    fileInputRef.current?.click();
  };

  const handleImageChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    setError('');

    if (!file) {
      return;
    }

    const acceptedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (!acceptedTypes.includes(file.type)) {
      setError('รูปแบบไฟล์ไม่ถูกต้อง!');
      return;
    }

    const fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > maxSize) {
      setError(`ไฟล์ใหญ่เกินไป! (สูงสุด ${maxSize}MB)`);
      return;
    }

    const imageDataUrl = await new Promise<string>((resolve) => {
      const reader = new FileReader();
      reader.onloadend = () => {
        resolve(reader.result as string);
      };
      reader.readAsDataURL(file);
    });

    if (autoPredictOnSelect) {
      await handlePredict(file, imageDataUrl);
      if (fileInputRef.current) {
        fileInputRef.current.value = '';
      }
    } else {
      if (showPreview) {
        setPreviewUrl(imageDataUrl);
      }
      setSelectedImage(file);
      onImageSelect?.(file);
    }
  };

  const handlePredict = async (file: File, imageDataUrl: string) => {
    setIsProcessing(true);
    setError('');
    setSelectedImage(null);
    setPreviewUrl(null);

    try {
      const userStr = localStorage.getItem('user');
      let userId = 0;

      if (userStr) {
        try {
          const user = JSON.parse(userStr);
          userId = user.id || 0;
        } catch (e) {
          console.error('Error parsing user from localStorage:', e);
        }
      }

      if (!userId) {
        setError('Please login first to use this feature!');
        setIsProcessing(false);
        return;
      }

      const result = await predictFood(userId, file);

      if (!result.success || !result.data) {
        setError(result.message || 'Failed to predict food. Please try again.');
        setIsProcessing(false);
        return;
      }

      if (result.data.warning) {
        setError(result.data.warning + ' Please upload a clearer image!');
        setIsProcessing(false);
        return;
      }

      if (result.data.confidence < 0.5) {
        setError('Image is unclear or not food. Please upload a clearer food image!');
        setIsProcessing(false);
        return;
      }

      if (result.data.food_id && result.data.nutrition) {
        sessionStorage.setItem('foodImage', imageDataUrl);

        const params = new URLSearchParams({
          foodName: encodeURIComponent(result.data.predicted_food),
          foodId: result.data.food_id.toString(),
          carbs: result.data.nutrition.carbohydrate_gram.toString(),
          fat: result.data.nutrition.fat_gram.toString(),
          protein: result.data.nutrition.protein_gram.toString(),
          calories: result.data.nutrition.calories.toString(),
          confidence: result.data.confidence.toString()
        });

        router.push(`/FoodDetailScreen?${params.toString()}`);
      } else {
        setError('No nutrition data available for this food!');
        setIsProcessing(false);
      }
    } catch (error: any) {
      console.error('Prediction error:', error);
      setError(error.message || 'Failed to predict food. Please try again.');
      setIsProcessing(false);
    }
  };

  const handleRemoveImage = () => {
    setSelectedImage(null);
    setPreviewUrl(null);
    setError('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
    onImageSelect?.(null);
  };

  return (
    <div className="space-y-4">
      {/* Upload Button */}
      <button
        type="button"
        onClick={handleButtonClick}
        disabled={isProcessing}
        className={`bg-gradient-to-r from-[#c8e6c9] to-[#a5d6a7] hover:from-[#a5d6a7] hover:to-[#81c784] border-6 border-black px-6 py-3 transition-all hover:translate-x-1 hover:translate-y-1 relative inline-flex items-center gap-3 ${
          isProcessing ? 'opacity-50 cursor-not-allowed' : ''
        }`}
        style={{
          fontFamily: 'TA8bit',
          boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
          imageRendering: 'pixelated'
        }}
      >
        <div className="absolute -top-1 -left-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -top-1 -right-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -bottom-1 -left-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-[#66bb6a]"></div>

        <div className="relative w-10 h-10 ">
        <Image
            src="/pic/addphoto.png"
            alt="Upload"
            fill
            sizes="40px"
        />
        </div>

        <span
          className="font-bold text-gray-900"
          style={{ textShadow: '2px 2px 0px rgba(0,0,0,0.1)' }}
        >
          {isProcessing ? 'Processing...' : buttonText}
        </span>

        <input
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/png,image/jpg,image/webp"
          onChange={handleImageChange}
          className="hidden"
        />
      </button>

      {/* Selected File Info */}
      {selectedImage && !autoPredictOnSelect && (
        <div
          className="bg-white border-4 border-black p-3 relative inline-block"
          style={{
            boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
            fontFamily: 'TA8bit'
          }}
        >
          <div className="flex items-center gap-3">
            <span className="text-green-600 font-bold">✓</span>
            <span className="text-sm text-gray-700 font-bold">{selectedImage.name}</span>
            <button
              type="button"
              onClick={handleRemoveImage}
              className="ml-2 text-red-600 hover:text-red-800 font-bold"
            >
              ✖
            </button>
          </div>
        </div>
      )}

      {/* Error Message */}
      {error && (
        <div
          className="bg-red-200 border-4 border-red-600 p-3 relative inline-block"
          style={{
            fontFamily: 'TA8bit',
            boxShadow: '4px 4px 0px rgba(220,38,38,0.3)'
          }}
        >
          <div className="flex items-center gap-2">
            <span className="text-xl">⚠</span>
            <span className="text-sm font-bold text-red-800">{error}</span>
          </div>
        </div>
      )}

      {/* Image Preview */}
      {showPreview && previewUrl && (
        <div
          className="bg-white border-6 border-black p-4 relative"
          style={{
            boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}
        >
          <div className="relative w-full h-48 bg-gray-100 border-4 border-black">
            <Image
              src={previewUrl}
              alt="Preview"
              fill
              className="object-contain"
            />
          </div>
        </div>
      )}

      {/* Processing Modal */}
      {isProcessing && (
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
                <h3 className="text-2xl font-bold text-white tracking-wider" style={{ textShadow: '3px 3px 0px rgba(0,0,0,0.3)' }}>
                  ★ PROCESSING ★
                </h3>
              </div>

              <div className="flex justify-center mb-4">
                <div className="text-6xl animate-bounce">🍔</div>
              </div>

              <div className="bg-white border-4 border-black p-4 mb-6">
                <p className="text-xl font-bold text-gray-800 mb-2" style={{ fontFamily: 'TA8bit' }}>
                  ANALYZING FOOD...
                </p>
                <p className="text-sm text-gray-600" style={{ fontFamily: 'TA8bit' }}>
                  Please wait while we identify your meal
                </p>
              </div>

              <div className="bg-black border-4 border-[#6fa85e] p-2">
                <div className="bg-[#2d2d2d] h-6 relative overflow-hidden">
                  <div
                    className="absolute top-0 left-0 h-full bg-gradient-to-r from-[#4ecdc4] to-[#44a3c4]"
                    style={{
                      animation: 'loadingBar 2s ease-in-out infinite',
                      width: '100%'
                    }}
                  >
                    <div className="absolute top-0 left-0 w-full h-2 bg-white opacity-30"></div>
                  </div>
                </div>
              </div>

              <p className="text-xs text-white mt-3" style={{ fontFamily: 'TA8bit', textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                Predicting...
              </p>
            </div>
          </div>
        </div>
      )}

      <style jsx>{`
        @keyframes loadingBar {
          0% { width: 0%; }
          50% { width: 100%; }
          100% { width: 0%; }
        }
      `}</style>
    </div>
  );
}