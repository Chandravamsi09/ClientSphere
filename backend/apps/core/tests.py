from django.test import TestCase
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient


class CoreApiFoundationTests(TestCase):
    """
    Automated verification for ClientSphere Django backend foundation endpoints.
    """

    def setUp(self):
        self.client = APIClient()

    def test_health_check_endpoint(self):
        url = reverse('core:health-check')
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data.get('status'), 'ok')
        self.assertEqual(data.get('service'), 'ClientSphere Backend API')
        self.assertEqual(data.get('framework'), 'Django + Django REST Framework')

    def test_api_root_endpoint(self):
        url = reverse('core:api-root')
        response = self.client.get(url)

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data.get('name'), 'ClientSphere CRM API')
        self.assertIn('endpoints', data)
        self.assertIn('health', data['endpoints'])

    def test_cors_headers_present_on_response(self):
        url = reverse('core:health-check')
        response = self.client.get(url, HTTP_ORIGIN='http://localhost:5000')

        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.headers.get('Access-Control-Allow-Origin'), 'http://localhost:5000')
