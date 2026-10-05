import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { DataService } from '../services/data.service';
import { Observable, map } from 'rxjs';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.html',
  styleUrls: ['./dashboard.css']
})
export class DashboardComponent implements OnInit {
  // Use 'any[]' or define an Interface for better Type safety
  inspections$!: Observable<any[]>;

  constructor(private dataService: DataService) {}

  ngOnInit(): void {
    this.inspections$ = this.dataService.getRecentInspections().pipe(
      map(actions => actions.map(data => {
        const isFlagged = data['scanHistory']?.some((item: any) => 
          item.label.toLowerCase() !== 'fresh'
        );

        return {
          ...data,
          displayId: data['id'] ? data['id'].substring(0, 6).toUpperCase() : 'N/A',
          isFlagged: isFlagged,
          statusText: isFlagged ? 'FLAGGED' : 'PASS',
          description: isFlagged ? 
            'Anomaly detected in sample indices. Threshold exceeded.' : 
            'Visual scan complete. All metrics within standard deviation.'
        };
      }))
    );
  }
}