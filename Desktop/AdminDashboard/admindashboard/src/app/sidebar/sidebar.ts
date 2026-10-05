import { Component } from '@angular/core';
import { Router, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './sidebar.html',
  styleUrls: ['./sidebar.css']
})
export class SidebarComponent {

  // Define nav items in an array to keep the HTML clean
  navItems = [
    { path: '/portal/dashboard', label: 'DASHBOARD', icon: '📊' },
    { path: '/portal/inspections', label: 'INSPECTIONS', icon: '📝' },
    { path: '/portal/history', label: 'BATCH HISTORY', icon: '📦' },
    { path: '/portal/reports', label: 'REPORTS', icon: '📈' },
    { path: '/portal/compliance', label: 'COMPLIANCE', icon: '🛡️' }
  ];

  constructor(private router: Router) {}

  logout() {
    // Add your Firebase or Auth logout logic here
    console.log('Logging out...');
    // Example: this.authService.signOut();
    this.router.navigate(['/login']);
  }
}