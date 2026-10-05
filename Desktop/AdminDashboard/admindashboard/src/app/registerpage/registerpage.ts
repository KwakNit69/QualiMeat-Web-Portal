import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-register',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './registerpage.html',
  styleUrls: ['./registerpage.css']
})
export class RegisterComponent {
  registrationData = {
    fullName: '',
    email: '',
    confirmEmail: '',
    password: '',
    confirmPassword: '',
    stallNumber: ''
  };

  onRegister() {
    console.log('Registration Data:', this.registrationData);
    // Add logic here to connect to Firebase or your Backend API
  }
}