import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd, RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';
import { SidebarComponent } from './sidebar/sidebar'; 
import { filter } from 'rxjs/operators';
import { NavbarComponent } from './navbar/navbar';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule, 
    RouterModule, 
    SidebarComponent,
    NavbarComponent 
  ],
  templateUrl: './app.html',
  styleUrls: ['./app.css']
})
export class AppComponent implements OnInit {
  showSidebar = false;

  constructor(public router: Router) {}

  ngOnInit() {
    // 1. Check the route immediately on load (for refreshes)
    this.updateSidebarVisibility(this.router.url);

    // 2. Watch for future navigation changes
    this.router.events.pipe(
      filter(event => event instanceof NavigationEnd)
    ).subscribe((event: any) => {
      this.updateSidebarVisibility(event.urlAfterRedirects);
    });
  }

  private updateSidebarVisibility(url: string) {

    const authPages = ['/login', '/register', '/about'];
    
    this.showSidebar = !authPages.some(page => url.includes(page));
  }
}