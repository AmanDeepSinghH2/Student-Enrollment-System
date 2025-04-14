console.log("auth_debug_v2.js loaded successfully");

function handleLogin(event) {
    console.log("handleLogin function called");
    try {
        if (!event) {
            console.error("No event object received");
            return;
        }
        
        event.preventDefault();
        console.log("Default form submission prevented");
        
        const form = event.target;
        if (!form) {
            console.error("No form element found in event");
            return;
        }
        
        console.log("Form ID:", form.id);
        const isFacultyLogin = form.id === 'facultyLoginForm';
        
        const username = isFacultyLogin 
            ? document.getElementById('facultyUsername').value
            : document.getElementById('studentUsername').value;
            
        const password = isFacultyLogin
            ? document.getElementById('facultyPassword').value
            : document.getElementById('studentPassword').value;

        console.log(`Username: ${username}, Password: ${password}, Is Faculty Login: ${isFacultyLogin}`);

        // Basic validation
        if (username && password) {
            console.log("Login successful, redirecting...");
            // Redirect based on login type
            if (isFacultyLogin) {
                window.location.href = 'faculty_dashboard.html';
            } else {
                window.location.href = 'student_dashboard.html';
            }
        } else {
            console.log("Login failed, missing credentials.");
            alert('Please enter both username and password');
        }
    } catch (error) {
        console.error("Error in handleLogin:", error);
    }
}

function handleGoogleLogin() {
    console.log("Google login initiated.");
    const isFacultyLogin = event.target.closest('#facultyLoginForm') !== null;
    
    gapi.load('auth2', function() {
        gapi.auth2.init({
            client_id: '485650101708-g36cvunsmn1vel2p171hts546ubs2ipf.apps.googleusercontent.com'
        }).then(function(auth2) {
            auth2.signIn().then(function(googleUser) {
                var profile = googleUser.getBasicProfile();
                console.log('ID: ' + profile.getId());
                console.log('Name: ' + profile.getName());
                console.log('Image URL: ' + profile.getImageUrl());
                console.log('Email: ' + profile.getEmail());
                // Redirect based on login type
                console.log("Google login successful, redirecting...");
                if (isFacultyLogin) {
                    window.location.href = 'faculty_dashboard.html';
                } else {
                    window.location.href = 'student_dashboard.html';
                }
            });
        });
    });
}

function selectSemester(semester) {
    console.log("Semester selection initiated.");
    // In a real app, you would save the selected semester and redirect to enrollment
    console.log(`Selected semester: ${semester}`);
    alert(`You selected Semester ${semester}. This would proceed to enrollment in a real application.`);
}
