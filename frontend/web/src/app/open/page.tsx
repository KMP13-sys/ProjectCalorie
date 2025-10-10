export default function OpenPage() {
  return (
    <div className="min-h-screen bg-[#DBFFC8] flex flex-col items-center justify-center">
      <div className="flex flex-col items-center ">
        {/* Logo Image */}
        <img 
          src="/pic/logoja.png" 
          className="w-150 h-150 object-contain pixelated"
        />
        
        {/* App Name */}
        <h1 className="text-[40px] font-bold text-gray-800 tracking-wider">
          CAL-DEFICITS
        </h1>
      </div>
    </div>
  );
}