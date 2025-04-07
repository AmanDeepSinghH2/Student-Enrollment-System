function handleLogin(event) {
    event.preventDefault();
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    // Basic validation
    if (username && password) {
        // In a real app, you would verify credentials with a server
        window.location.href = 'semester_selection.html';
    } else {
        alert('Please enter both username and password');
    }
}

function handleGoogleLogin() {
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
                // Redirect to semester selection after Google login
                window.location.href = 'semester_selection.html';
            });
        });
    });
}

function selectSemester(semester) {
    // In a real app, you would save the selected semester and redirect to enrollment
    console.log(`Selected semester: ${semester}`);
    alert(`You selected Semester ${semester}. This would proceed to enrollment in a real application.`);
}
