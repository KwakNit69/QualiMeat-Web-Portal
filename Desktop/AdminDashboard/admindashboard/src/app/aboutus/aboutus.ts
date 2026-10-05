import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-about',
  standalone: true,
  imports: [CommonModule, RouterLink], // Much cleaner!
  templateUrl: './aboutus.html',
  styleUrls: ['./aboutus.css']
})
export class AboutComponent {
  stats = [
    { label: 'Certified Stalls', value: '500+' },
    { label: 'Daily Inspections', value: '1.2k' },
    { label: 'Precision Rating', value: '99.9%' }
  ];
}