// app/main/page.tsx
'use client';

import { useState, useEffect } from 'react';
import NavBarUser from '../componants/NavBarUser';
import Kcalbar from '../componants/Kcalbar';
import Piegraph from '../componants/Piegraph';
import Activityfactor from '../componants/activityfactor';
import Camera from '../componants/camera';
import ListMenu from '../componants/ListMenu';
import ListSport from '../componants/ListSport';
import RacMenu from '../componants/RecMenu';
import RacSport from '../componants/RecSport';
import WeeklyGraph from '../componants/WeeklyGraph';
import { kalService } from '../services/kal_service';
import Activity from '../componants/Activity';

export default function MainPage() {
  const [hasActivityLevel, setHasActivityLevel] = useState(false);
  const [kcalbarKey, setKcalbarKey] = useState(0);
  const [pieKey, setPieKey] = useState(0);
  const [listSportKey, setListSportKey] = useState(0);
  const [remainingCalories, setRemainingCalories] = useState<number>(0);

  useEffect(() => {
    checkActivityLevel();
  }, []);

  useEffect(() => {
    const handleVisibilityChange = () => {
      if (!document.hidden) {
        console.log('🔄 Page visible, refreshing data...');
        setKcalbarKey(prev => prev + 1);
        setPieKey(prev => prev + 1);
        setListSportKey(prev => prev + 1);
      }
    };

    document.addEventListener('visibilitychange', handleVisibilityChange);

    const refreshOnMount = () => {
      console.log('🔄 Component mounted, refreshing...');
      setKcalbarKey(prev => prev + 1);
      setPieKey(prev => prev + 1);
      setListSportKey(prev => prev + 1);
    };

    const timer = setTimeout(refreshOnMount, 100);

    return () => {
      document.removeEventListener('visibilitychange', handleVisibilityChange);
      clearTimeout(timer);
    };
  }, []);

  const checkActivityLevel = async () => {
    try {
      const status = await kalService.getCalorieStatus();
      setHasActivityLevel(status.target_calories > 0);
    } catch (e) {
      console.error('Error checking activity level:', e);
      setHasActivityLevel(false);
    }
  };

  const handleActivityUpdated = () => {
    console.log('🔄 Activity updated, refreshing...');
    setHasActivityLevel(true);
    setKcalbarKey(prev => prev + 1);
    setPieKey(prev => prev + 1);
  };

  return (
    <div className="min-h-screen bg-gray-100">
      {/* NavBar */}
      <NavBarUser />

      {/* 🔹 MAIN LAYOUT AREA */}
      <div className="p-2 sm:p-3 md:p-4 lg:p-6 space-y-3 sm:space-y-4 md:space-y-6">
        
        {/* ======================================================= */}
        {/* ROW 1: Main Content Grid */}
        {/* ======================================================= */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-3 sm:gap-4 md:gap-5 lg:items-start">

          {/* 1. Kcalbar & Pie Graph */}
          <div className="md:col-span-1 lg:col-span-4 flex flex-col bg-white rounded-lg shadow-md p-2 sm:p-3 md:p-4 lg:h-[70vh]">
            <div className="h-[100px] sm:h-[110px] md:h-[120px]">
              <Kcalbar key={kcalbarKey} />
            </div>
            <div className="flex-1 overflow-hidden">
              <Piegraph key={pieKey} />
            </div>
          </div>

          {/* 2. Controls (Activity Factor, Camera, Activity) */}
          <div className="md:col-span-1 lg:col-span-2 flex flex-col space-y-3 sm:space-y-4 md:space-y-6 lg:space-y-8 bg-white rounded-lg shadow-md py-3 px-3 sm:py-4 sm:px-4 md:py-5 md:px-4 lg:h-[70vh]">
            <div>
              <Activityfactor onCaloriesUpdated={handleActivityUpdated} />
            </div>

            {hasActivityLevel ? (
              <div className="h-8 sm:h-9 md:h-10 bg-gray-200 flex items-center justify-center rounded-md">
                <Camera autoPredictOnSelect={true} />
              </div>
            ) : null}

            <Activity onSave={(burnedCalories: number) => {
              setKcalbarKey(prev => prev + 1);
              setPieKey(prev => prev + 1);
              setListSportKey(prev => prev + 1);
            }} />
          </div>

          {/* 3. List MENU */}
          <div className="md:col-span-1 lg:col-span-3 h-fit">
            <ListMenu />
          </div>

          {/* 4. List Sport */}
          <div className="md:col-span-1 lg:col-span-3 h-fit">
            <ListSport key={listSportKey} />
          </div>
        </div>

        {/* ======================================================= */}
        {/* ROW 2: Statistics & Recommendations */}
        {/* ======================================================= */}
        <div className="flex flex-col lg:flex-row gap-3 sm:gap-4 md:gap-6">
          
          {/* 5. Weekly Graph */}
          <div className="w-full lg:w-1/2 bg-white rounded-lg shadow-md min-h-[300px] sm:min-h-[350px] md:min-h-[400px] lg:h-[40vh]">
            <WeeklyGraph />
          </div>

          {/* Container for Recommendations */}
          <div className="w-full lg:w-1/2 flex flex-col sm:flex-row gap-3 sm:gap-4 md:gap-6">

            {/* 6. Recommend MENU */}
            <div className="flex-1 min-h-[250px] sm:min-h-[300px] lg:min-h-0">
              <RacMenu remainingCalories={remainingCalories} refreshTrigger={kcalbarKey} />
            </div>

            {/* 7. Recommend Sport */}
            <div className="flex-1 min-h-[250px] sm:min-h-[300px] lg:min-h-0">
              <RacSport refreshTrigger={listSportKey} />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}