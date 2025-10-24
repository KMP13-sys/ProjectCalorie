'use client';

import { useState, useRef } from 'react';
import Image from 'next/image';

interface ImageUploadButtonProps {
  onImageSelect?: (file: File | null) => void;
  buttonText?: string;
  maxSize?: number; // MB
  showPreview?: boolean;
}

export default function ImageUploadButton({ 
  onImageSelect,
  buttonText = 'แนบรูปอาหาร',
  maxSize = 5,
  showPreview = false
}: ImageUploadButtonProps) {
  const [selectedImage, setSelectedImage] = useState<File | null>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState<string>('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleButtonClick = () => {
    fileInputRef.current?.click();
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    setError('');

    if (!file) {
      return;
    }

    // Validate file type
    const acceptedTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
    if (!acceptedTypes.includes(file.type)) {
      setError('รูปแบบไฟล์ไม่ถูกต้อง!');
      return;
    }

    // Validate file size
    const fileSizeMB = file.size / (1024 * 1024);
    if (fileSizeMB > maxSize) {
      setError(`ไฟล์ใหญ่เกินไป! (สูงสุด ${maxSize}MB)`);
      return;
    }

    // Create preview URL
    if (showPreview) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setPreviewUrl(reader.result as string);
      };
      reader.readAsDataURL(file);
    }

    setSelectedImage(file);
    onImageSelect?.(file);
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
        className="bg-gradient-to-r from-[#c8e6c9] to-[#a5d6a7] hover:from-[#a5d6a7] hover:to-[#81c784] border-6 border-black px-6 py-3 transition-all hover:translate-x-1 hover:translate-y-1 relative inline-flex items-center gap-3"
        style={{ 
          fontFamily: 'monospace',
          boxShadow: '6px 6px 0px rgba(0,0,0,0.3)',
          imageRendering: 'pixelated'
        }}
      >
        {/* Decorative Corner Pixels */}
        <div className="absolute -top-1 -left-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -top-1 -right-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -bottom-1 -left-1 w-3 h-3 bg-[#66bb6a]"></div>
        <div className="absolute -bottom-1 -right-1 w-3 h-3 bg-[#66bb6a]"></div>

        {/* Icon from your file */}
        <div className="relative w-10 h-10 ">
        <Image
            src="/pic/addphoto.png"
            alt="Upload"
            fill
        />
        </div>
        
        {/* Button Text */}
        <span 
          className="font-bold text-gray-900"
          style={{ textShadow: '2px 2px 0px rgba(0,0,0,0.1)' }}
        >
          {buttonText}
        </span>

        {/* Hidden Input */}
        <input
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/png,image/jpg,image/webp"
          onChange={handleImageChange}
          className="hidden"
        />
      </button>

      {/* Selected File Info */}
      {selectedImage && (
        <div 
          className="bg-white border-4 border-black p-3 relative inline-block"
          style={{ 
            boxShadow: '4px 4px 0px rgba(0,0,0,0.3)',
            fontFamily: 'monospace'
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
            fontFamily: 'monospace',
            boxShadow: '4px 4px 0px rgba(220,38,38,0.3)'
          }}
        >
          <div className="flex items-center gap-2">
            <span className="text-xl">⚠</span>
            <span className="text-sm font-bold text-red-800">{error}</span>
          </div>
        </div>
      )}

      {/* Preview (Optional) */}
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
    </div>
  );
}