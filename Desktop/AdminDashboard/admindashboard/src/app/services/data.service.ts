import { Injectable } from '@angular/core';
import { Firestore, collection, query, orderBy, limit, collectionData } from '@angular/fire/firestore';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class DataService {
  // The red line here disappears once you add provideFirestore() to app.config.ts
  constructor(private firestore: Firestore) {}

  getRecentInspections(): Observable<any[]> {
    const inspectionsRef = collection(this.firestore, 'inspections');
    const q = query(inspectionsRef, orderBy('timestamp', 'desc'), limit(5));
    // collectionData returns an observable of the actual data objects
    return collectionData(q, { idField: 'id' });
  }
}