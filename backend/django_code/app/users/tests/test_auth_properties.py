"""
Property-based tests for user authentication APIs.

These tests validate universal correctness properties using hypothesis.
"""
from hypothesis import given, strategies as st, settings, assume
from hypothesis.extra.django import TestCase
from users.models import CustomUser
import json


class AuthPropertyTests(TestCase):
    """Property-based tests for authentication endpoints."""

    # Feature: user-authentication, Property 2: Password Mismatch Rejection
    # **Validates: Requirements 1.2**
    @settings(max_examples=100)
    @given(
        username=st.text(
            alphabet=st.characters(whitelist_categories=('L', 'N'), whitelist_characters='_'),
            min_size=3,
            max_size=20
        ),
        email=st.emails(),
        password1=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
        password2=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
    )
    def test_password_mismatch_rejected(self, username, email, password1, password2):
        """
        Property 2: Password Mismatch Rejection
        
        *For any* registration request where password != confirmPassword, 
        the Auth_System SHALL reject the request with an error response (status code 400) 
        and the response SHALL contain an error message.
        """
        # Ensure passwords are different
        assume(password1 != password2)
        # Ensure username is valid (not empty after strip)
        assume(username.strip())
        
        response = self.client.post(
            '/api/users/register/',
            data=json.dumps({
                'username': username,
                'email': email,
                'password': password1,
                'confirm_password': password2,
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)

    # Feature: user-authentication, Property 3: Empty Field Validation Rejection
    # **Validates: Requirements 1.4, 2.3**
    @settings(max_examples=100)
    @given(
        password=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
    )
    def test_empty_username_rejected_register(self, password):
        """
        Property 3: Empty Field Validation Rejection (Registration - Empty Username)
        
        *For any* authentication request (registration) where username is empty or whitespace-only,
        the Auth_System SHALL reject the request with an error response (status code 400).
        """
        # Test with empty string
        response = self.client.post(
            '/api/users/register/',
            data=json.dumps({
                'username': '',
                'email': 'test@example.com',
                'password': password,
                'confirm_password': password,
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)

    @settings(max_examples=100)
    @given(
        whitespace=st.text(alphabet=' \t\n', min_size=1, max_size=10),
        password=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
    )
    def test_whitespace_username_rejected_register(self, whitespace, password):
        """
        Property 3: Empty Field Validation Rejection (Registration - Whitespace Username)
        
        *For any* authentication request (registration) where username is whitespace-only,
        the Auth_System SHALL reject the request with an error response (status code 400).
        """
        response = self.client.post(
            '/api/users/register/',
            data=json.dumps({
                'username': whitespace,
                'email': 'test@example.com',
                'password': password,
                'confirm_password': password,
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)

    @settings(max_examples=100)
    @given(
        password=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
    )
    def test_empty_username_rejected_login(self, password):
        """
        Property 3: Empty Field Validation Rejection (Login - Empty Username)
        
        *For any* authentication request (login) where username is empty or whitespace-only,
        the Auth_System SHALL reject the request with an error response (status code 400).
        """
        response = self.client.post(
            '/api/users/login/',
            data=json.dumps({
                'username': '',
                'password': password,
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)

    @settings(max_examples=100)
    @given(
        whitespace=st.text(alphabet=' \t\n', min_size=1, max_size=10),
        password=st.text(min_size=8, max_size=50, alphabet=st.characters(whitelist_categories=('L', 'N', 'P'))),
    )
    def test_whitespace_username_rejected_login(self, whitespace, password):
        """
        Property 3: Empty Field Validation Rejection (Login - Whitespace Username)
        
        *For any* authentication request (login) where username is whitespace-only,
        the Auth_System SHALL reject the request with an error response (status code 400).
        """
        response = self.client.post(
            '/api/users/login/',
            data=json.dumps({
                'username': whitespace,
                'password': password,
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)

    @settings(max_examples=100)
    @given(
        username=st.text(
            alphabet=st.characters(whitelist_categories=('L', 'N'), whitelist_characters='_'),
            min_size=3,
            max_size=20
        ),
    )
    def test_empty_password_rejected_login(self, username):
        """
        Property 3: Empty Field Validation Rejection (Login - Empty Password)
        
        *For any* authentication request (login) where password is empty,
        the Auth_System SHALL reject the request with an error response (status code 400).
        """
        assume(username.strip())
        
        response = self.client.post(
            '/api/users/login/',
            data=json.dumps({
                'username': username,
                'password': '',
            }),
            content_type='application/json'
        )
        
        self.assertEqual(response.status_code, 400)
        response_data = response.json()
        self.assertIn('error', response_data)
