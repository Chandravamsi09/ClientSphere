from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

User = get_user_model()


class AuthenticationModuleTests(APITestCase):
    """
    Automated integration tests for ClientSphere CRM Authentication module.
    """

    def setUp(self):
        self.register_url = reverse('authentication:register')
        self.login_url = reverse('authentication:login')
        self.refresh_url = reverse('authentication:token-refresh')
        self.profile_url = reverse('authentication:current-user-profile')
        self.change_password_url = reverse('authentication:change-password')
        self.logout_url = reverse('authentication:logout')

        # Baseline test user
        self.base_password = "SecurePassword123!"
        self.user = User.objects.create_user(
            username="testagent",
            email="agent@clientsphere.com",
            password=self.base_password,
            first_name="Jane",
            last_name="Doe",
            phone="+1234567890",
            role="sales_rep",
            quota=50000.00,
            achieved=12500.00,
        )

    def test_user_registration_success(self):
        payload = {
            "username": "newrep",
            "email": "newrep@clientsphere.com",
            "password": "StrongSecret2026!",
            "first_name": "Alex",
            "last_name": "Smith",
            "phone": "+1987654321",
            "role": "sales_rep",
        }
        response = self.client.post(self.register_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data.get("message"), "User registered successfully.")
        self.assertIn("user", data)
        self.assertEqual(data["user"]["email"], "newrep@clientsphere.com")
        self.assertEqual(data["user"]["username"], "newrep")
        # Ensure password is never exposed in response
        self.assertNotIn("password", data["user"])

        # Verify password is properly hashed in database
        created_user = User.objects.get(username="newrep")
        self.assertTrue(created_user.check_password("StrongSecret2026!"))

    def test_user_registration_duplicate_email_rejected(self):
        payload = {
            "username": "duplicate_agent",
            "email": "agent@clientsphere.com",  # same as self.user
            "password": "AnotherPassword123!",
        }
        response = self.client.post(self.register_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", response.json())

    def test_user_registration_short_password_rejected(self):
        payload = {
            "username": "shortpass_agent",
            "email": "short@clientsphere.com",
            "password": "short",
        }
        response = self.client.post(self.register_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("password", response.json())

    def test_user_login_success(self):
        payload = {
            "username": "testagent",
            "password": self.base_password,
        }
        response = self.client.post(self.login_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertIn("access", data)
        self.assertIn("refresh", data)
        self.assertIn("user", data)
        self.assertEqual(data["user"]["email"], "agent@clientsphere.com")
        self.assertEqual(data["user"]["role"], "sales_rep")

    def test_user_login_invalid_credentials(self):
        payload = {
            "username": "testagent",
            "password": "WrongPassword!",
        }
        response = self.client.post(self.login_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_token_refresh(self):
        # First obtain token
        login_res = self.client.post(self.login_url, {
            "username": "testagent",
            "password": self.base_password,
        }, format='json')
        refresh_token = login_res.json()["refresh"]

        # Use refresh token
        refresh_res = self.client.post(self.refresh_url, {
            "refresh": refresh_token,
        }, format='json')

        self.assertEqual(refresh_res.status_code, status.HTTP_200_OK)
        self.assertIn("access", refresh_res.json())

    def test_profile_requires_authentication(self):
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_profile_authenticated_access_and_update(self):
        # Authenticate
        self.client.force_authenticate(user=self.user)

        # GET profile
        response = self.client.get(self.profile_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data["username"], "testagent")
        self.assertEqual(float(data["quota"]), 50000.00)
        self.assertEqual(float(data["achieved"]), 12500.00)

        # PATCH profile
        patch_res = self.client.patch(self.profile_url, {
            "first_name": "Janet",
            "phone": "+1000000000",
            "quota": 999999.00,  # read-only, should be ignored
        }, format='json')

        self.assertEqual(patch_res.status_code, status.HTTP_200_OK)
        patch_data = patch_res.json()
        self.assertEqual(patch_data["first_name"], "Janet")
        self.assertEqual(patch_data["phone"], "+1000000000")
        self.assertEqual(float(patch_data["quota"]), 50000.00)  # Unchanged

    def test_change_password_success(self):
        self.client.force_authenticate(user=self.user)

        new_password = "BrandNewSecretPassword2026!"
        response = self.client.post(self.change_password_url, {
            "old_password": self.base_password,
            "new_password": new_password,
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_200_OK)

        # Verify old password no longer works for login
        self.client.force_authenticate(user=None)
        fail_login = self.client.post(self.login_url, {
            "username": "testagent",
            "password": self.base_password,
        }, format='json')
        self.assertEqual(fail_login.status_code, status.HTTP_401_UNAUTHORIZED)

        # Verify new password works for login
        success_login = self.client.post(self.login_url, {
            "username": "testagent",
            "password": new_password,
        }, format='json')
        self.assertEqual(success_login.status_code, status.HTTP_200_OK)

    def test_change_password_invalid_old_password(self):
        self.client.force_authenticate(user=self.user)

        response = self.client.post(self.change_password_url, {
            "old_password": "IncorrectOldPassword!",
            "new_password": "BrandNewSecretPassword2026!",
        }, format='json')

        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("old_password", response.json())

    def test_logout_endpoint(self):
        self.client.force_authenticate(user=self.user)
        response = self.client.post(self.logout_url, {"refresh": "dummy_or_real_token"}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.json().get("message"), "Logged out successfully.")
