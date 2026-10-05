import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app/app.routes';


// Add these Firebase imports
import { initializeApp, provideFirebaseApp } from '@angular/fire/app';
import { getFirestore, provideFirestore } from '@angular/fire/firestore';

const firebaseConfig = {
    apiKey: "AIzaSyA2c1f9guIlAXOiDTIUKyIXF-kGfl3xgDk",
    authDomain: "qualimeatdb.firebaseapp.com",
    projectId: "qualimeatdb",
    storageBucket: "qualimeatdb.firebasestorage.app",
    messagingSenderId: "247856692336",
    appId: "1:247856692336:web:e39f42000af793a7a308b5"
};

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(routes),
    // This connects the Firestore engine to your project
    provideFirebaseApp(() => initializeApp(firebaseConfig)),
    provideFirestore(() => getFirestore())
  ]
};