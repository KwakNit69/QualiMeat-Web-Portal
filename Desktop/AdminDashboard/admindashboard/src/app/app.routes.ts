import { Routes } from '@angular/router';
import { LoginComponent } from './loginpage/loginpage';
import { RegisterComponent } from './registerpage/registerpage';
import { AboutComponent } from './aboutus/aboutus';
import { DashboardComponent } from './dashboard/dashboard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  { path: 'about', component: AboutComponent },
  { path: 'dashboard', component: DashboardComponent },
  { path: '', redirectTo: 'login', pathMatch: 'full' }
];