from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import Contact, ContactLifecycleStage

User = get_user_model()


class ContactModuleTests(APITestCase):
    """
    Automated integration test suite for ClientSphere CRM Contacts module.
    """

    def setUp(self):
        self.list_create_url = reverse('contacts:contact-list')

        # Test users
        self.user_a = User.objects.create_user(
            username="rep_a",
            email="rep_a@clientsphere.com",
            password="SecurePassword123!",
            first_name="Alice",
            last_name="Adams",
            role="sales_rep",
        )
        self.user_b = User.objects.create_user(
            username="rep_b",
            email="rep_b@clientsphere.com",
            password="SecurePassword123!",
            first_name="Bob",
            last_name="Baker",
            role="sales_rep",
        )

        # Baseline contact
        self.contact = Contact.objects.create(
            first_name="John",
            last_name="Doe",
            email="john.doe@enterprise.com",
            phone="+1-555-0100",
            job_title="Procurement Director",
            department="Operations",
            company_name="Enterprise Corp",
            lifecycle_stage=ContactLifecycleStage.PROSPECT,
            city="New York",
            owner=self.user_a,
        )

    def detail_url(self, contact_id):
        return reverse('contacts:contact-detail', kwargs={'pk': contact_id})

    def test_unauthenticated_requests_blocked(self):
        # List
        res = self.client.get(self.list_create_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

        # Create
        res = self.client.post(self.list_create_url, {"first_name": "Ghost", "last_name": "User"})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_contact_success_with_default_owner(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "first_name": "Marcus",
            "last_name": "Vance",
            "email": "marcus.vance@techcorp.io",
            "phone": "+1-555-0199",
            "mobile": "+1-555-0198",
            "job_title": "CTO",
            "department": "Engineering",
            "company_name": "TechCorp Solutions",
            "lifecycle_stage": "lead",
            "city": "Austin",
            "state": "Texas",
            "country": "USA",
            "notes": "Met at SaaS Expo 2026.",
        }
        response = self.client.post(self.list_create_url, payload, format='json')

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data["first_name"], "Marcus")
        self.assertEqual(data["last_name"], "Vance")
        self.assertEqual(data["full_name"], "Marcus Vance")
        self.assertEqual(data["email"], "marcus.vance@techcorp.io")
        self.assertEqual(data["owner"], self.user_a.id)
        self.assertEqual(data["owner_name"], "Alice Adams")
        self.assertIn("created_at", data)

    def test_create_contact_validation_errors(self):
        self.client.force_authenticate(user=self.user_a)

        # Missing first_name & last_name
        res = self.client.post(self.list_create_url, {
            "email": "incomplete@domain.com"
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("first_name", res.json())
        self.assertIn("last_name", res.json())

        # Invalid email format
        res = self.client.post(self.list_create_url, {
            "first_name": "Bad",
            "last_name": "Email",
            "email": "not-an-email",
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", res.json())

        # Duplicate email
        res = self.client.post(self.list_create_url, {
            "first_name": "Duplicate",
            "last_name": "Person",
            "email": "john.doe@enterprise.com",  # matches self.contact
        }, format='json')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("email", res.json())

    def test_list_contacts_pagination(self):
        self.client.force_authenticate(user=self.user_a)

        # Create additional contacts
        for i in range(5):
            Contact.objects.create(
                first_name=f"LeadFirstName{i}",
                last_name=f"LeadLastName{i}",
                email=f"lead{i}@testcompany.com",
                owner=self.user_a,
            )

        response = self.client.get(self.list_create_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertIn("count", data)
        self.assertIn("results", data)
        self.assertEqual(data["count"], 6)  # 1 baseline + 5 created

    def test_search_contacts(self):
        self.client.force_authenticate(user=self.user_a)

        Contact.objects.create(
            first_name="Sarah",
            last_name="Connor",
            email="sarah.connor@cyberdyne.org",
            company_name="Cyberdyne Systems",
            owner=self.user_a,
        )

        # Search by company name
        res = self.client.get(f"{self.list_create_url}?search=Cyberdyne")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["first_name"], "Sarah")

        # Search by first name
        res = self.client.get(f"{self.list_create_url}?search=John")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 1)

        # Search with no match
        res = self.client.get(f"{self.list_create_url}?search=NonExistentEntity")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.json()["count"], 0)

    def test_filter_by_lifecycle_stage(self):
        self.client.force_authenticate(user=self.user_a)

        Contact.objects.create(
            first_name="VIP",
            last_name="Customer",
            email="vip@acme.com",
            lifecycle_stage=ContactLifecycleStage.CUSTOMER,
            owner=self.user_a,
        )

        res = self.client.get(f"{self.list_create_url}?lifecycle_stage=customer")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["email"], "vip@acme.com")

    def test_filter_by_mine_ownership(self):
        self.client.force_authenticate(user=self.user_a)

        Contact.objects.create(
            first_name="Other",
            last_name="Contact",
            email="other@external.com",
            owner=self.user_b,
        )

        # When filtering by mine=true, only user_a's contacts are returned
        res = self.client.get(f"{self.list_create_url}?mine=true")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["count"], 1)
        self.assertEqual(data["results"][0]["id"], self.contact.id)

    def test_retrieve_contact_detail(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.get(self.detail_url(self.contact.id))
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["id"], self.contact.id)
        self.assertEqual(data["email"], "john.doe@enterprise.com")
        self.assertEqual(data["job_title"], "Procurement Director")

        # 404 on non-existent
        res_404 = self.client.get(self.detail_url(99999))
        self.assertEqual(res_404.status_code, status.HTTP_404_NOT_FOUND)

    def test_update_contact_put(self):
        self.client.force_authenticate(user=self.user_a)

        payload = {
            "first_name": "Jonathan",
            "last_name": "Doe",
            "email": "john.doe@enterprise.com",
            "phone": "+1-555-9999",
            "job_title": "VP of Procurement",
            "department": "Executive",
            "company_name": "Enterprise Corp Global",
            "lifecycle_stage": "customer",
        }
        res = self.client.put(self.detail_url(self.contact.id), payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["first_name"], "Jonathan")
        self.assertEqual(data["job_title"], "VP of Procurement")
        self.assertEqual(data["lifecycle_stage"], "customer")

    def test_partial_update_contact_patch(self):
        self.client.force_authenticate(user=self.user_a)

        patch_payload = {
            "mobile": "+1-555-4321",
            "lifecycle_stage": "opportunity",
        }
        res = self.client.patch(self.detail_url(self.contact.id), patch_payload, format='json')
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        data = res.json()
        self.assertEqual(data["mobile"], "+1-555-4321")
        self.assertEqual(data["lifecycle_stage"], "opportunity")
        # Ensure other fields remain intact
        self.assertEqual(data["first_name"], "John")

    def test_delete_contact(self):
        self.client.force_authenticate(user=self.user_a)

        res = self.client.delete(self.detail_url(self.contact.id))
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)

        # Verify record no longer exists
        self.assertFalse(Contact.objects.filter(pk=self.contact.id).exists())
        res_after = self.client.get(self.detail_url(self.contact.id))
        self.assertEqual(res_after.status_code, status.HTTP_404_NOT_FOUND)
