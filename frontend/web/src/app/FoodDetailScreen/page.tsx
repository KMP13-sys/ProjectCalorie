'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Image from 'next/image';
import { saveMeal } from '../services/predict_service';
import NavBarUser from '../componants/NavBarUser';

interface FoodDetail {
  imageUrl: string;
  foodName: string;
  foodId: number;
  carbs: number;
  fat: number;
  protein: number;
  calories: number;
  confidence: number;
}

export default function FoodDetailScreen() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccessDialog, setShowSuccessDialog] = useState(false);
  const [errorDialog, setErrorDialog] = useState<{show: boolean, title: string, message: string}>({
    show: false,
    title: '',
    message: ''
  });
  const [foodDetail, setFoodDetail] = useState<FoodDetail | null>(null);

  useEffect(() => {
    // Only load data once when component mounts
    if (foodDetail) return; // Skip if already loaded

    // Get food details from URL parameters and sessionStorage
    const imageUrl = sessionStorage.getItem('foodImage'); // Get image from sessionStorage
    const foodName = searchParams.get('foodName');
    const foodId = searchParams.get('foodId');
    const carbs = searchParams.get('carbs');
    const fat = searchParams.get('fat');
    const protein = searchParams.get('protein');
    const calories = searchParams.get('calories');
    const confidence = searchParams.get('confidence');

    if (imageUrl && foodName && foodId && carbs && fat && protein && calories && confidence) {
      setFoodDetail({
        imageUrl: imageUrl,
        foodName: decodeURIComponent(foodName),
        foodId: parseInt(foodId),
        carbs: parseInt(carbs),
        fat: parseInt(fat),
        protein: parseInt(protein),
        calories: parseInt(calories),
        confidence: parseFloat(confidence)
      });

      // Don't clear sessionStorage here - clear only when leaving the page
    } else {
      // If no data, redirect back to main page
      console.log('No food data found, redirecting to main page');
      router.push('/main');
    }
  }, [searchParams, router, foodDetail]);

  const handleSaveMeal = async () => {
    if (isSaving || !foodDetail) return;

    setIsSaving(true);

    try {
      // Get userId from localStorage (stored in user object by auth_service)
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
        throw new Error('User not logged in. Please login first.');
      }

      const result = await saveMeal(userId, {
        food_id: foodDetail.foodId,
        confidence_score: foodDetail.confidence
      });

      if (result.success) {
        // Show success dialog
        setShowSuccessDialog(true);

        // Auto redirect after 2 seconds
        setTimeout(() => {
          sessionStorage.removeItem('foodImage');
          router.push('/main');
        }, 2000);
      } else {
        setErrorDialog({
          show: true,
          title: 'Error',
          message: result.message || 'Failed to save meal data'
        });
      }
    } catch (error: any) {
      setErrorDialog({
        show: true,
        title: 'Error',
        message: error.message || 'Failed to save meal. Please try again.'
      });
    } finally {
      setIsSaving(false);
    }
  };

  const handleBack = () => {
    // Clear any remaining image data
    sessionStorage.removeItem('foodImage');
    router.push('/main');
  };

  if (!foodDetail) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center font-mono">Loading...</div>
      </div>
    );
  }

  return (
    <>
      <style jsx global>{`
        body {
          background: linear-gradient(to bottom, #f0f4f0 0%, #e8ede8 100%) !important;
          background-attachment: fixed !important;
        }
      `}</style>

      <div style={{
        minHeight: '100vh',
        background: 'linear-gradient(to bottom, #f0f4f0 0%, #e8ede8 100%)',
        backgroundAttachment: 'fixed',
        position: 'relative'
      }}>
        {/* Pixel Art Background Pattern */}
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          opacity: 0.05,
          pointerEvents: 'none',
          backgroundImage: `
            repeating-linear-gradient(0deg, #000 0px, #000 1px, transparent 1px, transparent 20px),
            repeating-linear-gradient(90deg, #000 0px, #000 1px, transparent 1px, transparent 20px)
          `,
          zIndex: 0
        }}></div>

        {/* NavBar */}
        <div style={{ position: 'relative', zIndex: 1 }}>
          <NavBarUser />
        </div>

        <div className="py-8 px-6" style={{ position: 'relative', zIndex: 1 }}>
          <div className="max-w-5xl mx-auto">

            {/* Back Button */}
            <button
              onClick={handleBack}
              className="mb-6 p-2 bg-white border-4 border-black hover:bg-gray-100 transition-all hover:translate-x-1 hover:translate-y-1 relative z-10"
              style={{
                boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
                fontFamily: 'TA8bit',
                color: '#000000'
              }}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={3}
                stroke="currentColor"
                className="w-6 h-6"
                style={{ color: '#000000' }}
              >
                <path strokeLinecap="round" strokeLinejoin="round" d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
              </svg>
            </button>

          {/* Main Content Container */}
          <div className="bg-white border-8 border-black p-8 relative" style={{
            boxShadow: '12px 12px 0px rgba(0,0,0,0.3)',
            imageRendering: 'pixelated'
          }}>
            {/* Decorative Corner Pixels */}
            <div className="absolute -top-2 -left-2 w-6 h-6 bg-[#A3EBA1] border-2 border-black"></div>
            <div className="absolute -top-2 -right-2 w-6 h-6 bg-[#A3EBA1] border-2 border-black"></div>
            <div className="absolute -bottom-2 -left-2 w-6 h-6 bg-[#A3EBA1] border-2 border-black"></div>
            <div className="absolute -bottom-2 -right-2 w-6 h-6 bg-[#A3EBA1] border-2 border-black"></div>

            {/* Grid Layout: Image on left, Info on right */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">

              {/* Left: Food Image */}
              <div className="flex flex-col items-center">
                <div
                  className="w-full max-w-[400px] h-[350px] relative border-6 border-black bg-gray-100"
                  style={{
                    boxShadow: '8px 8px 0px rgba(0,0,0,0.2)',
                    imageRendering: 'pixelated'
                  }}
                >
                  {/* Pixel frame decoration */}
                  <div className="absolute -top-1 -left-1 w-3 h-3 bg-gray-800"></div>
                  <div className="absolute -top-1 -right-1 w-3 h-3 bg-gray-800"></div>
                  <div className="absolute -bottom-1 -left-1 w-3 h-3 bg-gray-800"></div>
                  <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-gray-800"></div>

                  <Image
                    src={foodDetail.imageUrl}
                    alt={foodDetail.foodName}
                    fill
                    className="object-cover"
                    style={{ imageRendering: 'auto' }}
                  />
                </div>
              </div>

              {/* Right: Food Information */}
              <div className="flex flex-col">
                {/* Header Box */}
                <div
                  className="bg-gradient-to-r from-[#A3EBA1] to-[#8bc273] border-4 border-black p-3 mb-4 relative"
                  style={{
                    boxShadow: '6px 6px 0px rgba(0,0,0,0.2)',
                    fontFamily: 'TA8bit'
                  }}
                >
                  <h2 className="text-2xl font-bold text-center text-gray-800" style={{
                    textShadow: '2px 2px 0px rgba(255,255,255,0.5)'
                  }}>
                    ★ What food is this ★
                  </h2>
                </div>

                {/* Info Container */}
                <div
                  className="border-6 border-black bg-gradient-to-b from-[#FFFFCC] to-[#FFFFAA] p-4 mb-6"
                  style={{
                    boxShadow: '6px 6px 0px rgba(0,0,0,0.2)',
                    fontFamily: 'TA8bit',
                    color: '#333333',
                    fontSize: '35px'
                  }}
                >
                  <InfoBox text={`Menu: ${foodDetail.foodName}`} />
                  <InfoBox text={`Carbs: ${foodDetail.carbs} g`} />
                  <InfoBox text={`Fat: ${foodDetail.fat} g`} />
                  <InfoBox text={`Protein: ${foodDetail.protein} g`} />
                  <InfoBox text={`Calories: ${foodDetail.calories} kcal`} />
                  <InfoBox text={`Confidence: ${(foodDetail.confidence * 100).toFixed(1)}%`} />
                </div>

                {/* Save Button */}
                <div className="flex justify-center">
                  <button
                    onClick={handleSaveMeal}
                    disabled={isSaving}
                    className={`w-full max-w-[250px] h-[55px] border-6 border-black font-mono font-bold text-xl transition-all relative ${
                      isSaving
                        ? 'bg-[#CCCCCC] cursor-not-allowed'
                        : 'bg-gradient-to-b from-[#A3EBA1] to-[#8bc273] hover:translate-x-2 hover:translate-y-2 active:translate-x-1 active:translate-y-1'
                    }`}
                    style={{
                      boxShadow: isSaving ? '3px 3px 0px rgba(0,0,0,0.3)' : '8px 8px 0px rgba(0,0,0,0.3)',
                      textShadow: '2px 2px 0px rgba(0,0,0,0.2)'
                    }}
                  >
                    {/* Button Corner Pixels */}
                    {!isSaving && (
                      <>
                        <div className="absolute -top-1 -left-1 w-2 h-2 bg-white"></div>
                        <div className="absolute -top-1 -right-1 w-2 h-2 bg-white"></div>
                      </>
                    )}

                    <span className="flex items-center justify-center gap-2">
                      {isSaving ? 'SAVING...' : 'SAVE'}
                    </span>
                  </button>
                </div>

                {/* Pixel Decoration */}
                <div className="flex justify-center mt-4 gap-1">
                  <div className="w-3 h-3 bg-[#A3EBA1] border border-black"></div>
                  <div className="w-3 h-3 bg-[#8bc273] border border-black"></div>
                  <div className="w-3 h-3 bg-[#A3EBA1] border border-black"></div>
                  <div className="w-3 h-3 bg-[#8bc273] border border-black"></div>
                  <div className="w-3 h-3 bg-[#A3EBA1] border border-black"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Success Dialog */}
      {showSuccessDialog && (
        <div className="fixed inset-0 bg-black bg-opacity-70 flex items-center justify-center p-4 z-50">
          <div
            className="bg-gradient-to-b from-[#a8d48f] to-[#8bc273] border-8 border-black w-full max-w-md relative"
            style={{
              boxShadow: '8px 8px 0px rgba(0,0,0,0.3)',
              imageRendering: 'pixelated'
            }}
          >
            {/* Decorative Corner Pixels */}
            <div className="absolute top-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute top-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 left-0 w-4 h-4 bg-[#6fa85e]"></div>
            <div className="absolute bottom-0 right-0 w-4 h-4 bg-[#6fa85e]"></div>

            <div className="p-8 text-center relative">
              {/* Header */}
              <div className="bg-[#6fa85e] border-b-4 border-black -mx-8 -mt-8 mb-6 py-3">
                <h3 className="text-2xl font-bold text-white tracking-wider" style={{ textShadow: '3px 3px 0px rgba(0,0,0,0.3)', fontFamily: 'TA8bit' }}>
                  ★ MEAL SAVED! ★
                </h3>
              </div>

              {/* Pixel Star Icon */}
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

              {/* Message Box */}
              <div className="bg-white border-4 border-black p-4 mb-6">
                <p className="text-xl font-bold text-gray-800 mb-2" style={{ fontFamily: 'TA8bit' }}>
                  MEAL SAVED!
                </p>
                <p className="text-sm text-gray-600" style={{ fontFamily: 'TA8bit' }}>
                  Your meal has been recorded successfully!
                </p>
              </div>

              <p className="text-xs text-white animate-pulse" style={{ fontFamily: 'TA8bit', textShadow: '2px 2px 0px rgba(0,0,0,0.5)' }}>
                Returning to main page...
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Error Dialog */}
      {errorDialog.show && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-6">
          <div
            className="bg-[#FFC1C1] border-4 border-black p-4 max-w-sm w-full"
            style={{
              boxShadow: '6px 6px 0px rgba(0,0,0,0.4)',
              fontFamily: 'TA8bit'
            }}
          >
            <div className="bg-[#FF6B6B] py-2 mb-4 -mx-4 -mt-4 px-4">
              <div className="font-bold text-center text-white">{errorDialog.title}</div>
            </div>

            <div className="text-center mb-5 text-sm">{errorDialog.message}</div>

            <div className="flex justify-center">
              <button
                onClick={() => setErrorDialog({show: false, title: '', message: ''})}
                className="w-[100px] py-2 bg-white border-[3px] border-black font-bold hover:bg-gray-100 transition-colors"
              >
                OK
              </button>
            </div>
          </div>
        </div>
      )}
      </div>
    </>
  );
}

function InfoBox({ text, icon }: { text: string; icon?: string }) {
  return (
    <div
      className="w-full bg-gradient-to-r from-[#FFFFDD] to-[#FFFFB3] border-2 border-[#FFD700] py-2 my-1 font-mono text-sm font-bold flex items-center justify-between px-4"
      style={{
        boxShadow: '2px 2px 0px rgba(0,0,0,0.1)'
      }}
    >
      {icon && <span className="text-lg mr-2">{icon}</span>}
      <span className="flex-1 text-left">{text}</span>
    </div>
  );
}
