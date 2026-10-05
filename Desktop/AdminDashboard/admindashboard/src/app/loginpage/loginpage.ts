import { Component } from '@angular/core';
import { Router } from '@angular/router'; // Ensure this is here!
import { FormsModule } from '@angular/forms'; 

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule], 
  templateUrl: './loginpage.html',
  styleUrls: ['./loginpage.css']
})
export class LoginComponent {

  // The 'private router' here creates the 'this.router' object
  constructor(private router: Router) {} 

  onLogin() {
    console.log("Login button clicked!"); // Check your browser console (F12) for this
    this.router.navigate(['/dashboard']); 
  }
}