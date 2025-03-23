function handleGoogleLogin() {
    gapi.load('auth2', function() {
        gapi.auth2.init({
            client_id: '485650101708-g36cvunsmn1vel2p171hts546ubs2ipf.apps.googleusercontent.com'
        }).then(function(auth2) {
            auth2.signIn().then(function(googleUser) {
                var profile = googleUser.getBasicProfile();
                console.log('ID: ' + profile.getId()); // Do not send to your backend! Use an ID token instead.
                console.log('Name: ' + profile.getName());
                console.log('Image URL: ' + profile.getImageUrl());
                console.log('Email: ' + profile.getEmail());
                // Handle successful login here (e.g., redirect to another page)
            });
        });
    });
}
