importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyDVpo_KOv4lorUEXrCIbHhT983MGQqMTKI",
  authDomain: "churchcontrol-1dff9.firebaseapp.com",
  projectId: "churchcontrol-1dff9",
  storageBucket: "churchcontrol-1dff9.firebasestorage.app",
  messagingSenderId: "176781023738",
  appId: "1:176781023738:web:4fddabc3c1dab16edeec43",
  measurementId: "G-HVYF9NBMD8"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);

  const notificationTitle = payload.notification?.title || 'ChurchControl';
  const notificationOptions = {
    body: payload.notification?.body || 'Nova notificacao',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  console.log('[firebase-messaging-sw.js] Notification click:', event);
  event.notification.close();

  // Open the app when notification is clicked
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // If app is already open, focus it
      for (const client of clientList) {
        if ('focus' in client) {
          return client.focus();
        }
      }
      // Otherwise, open new window
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
