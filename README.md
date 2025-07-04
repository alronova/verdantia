# Verdantia: The Virtual Botanical Lab

Verdantia is a mobile application aiming to transform plant care into an engaging, gamified experience through immersive 2D pixel-art simulations, personalized interactions, and AI-powered learning. This document outlines the design process, core principles, and key design components that will guide the development of a user-centric and aesthetically pleasing application. The goal is to bridge the gap between growing interest in green living and the intimidation many feel towards gardening, making plant care fun, accessible, and rewarding.

- Gamification: Introducing XP, levels, and coins to motivate users and reward consistent care and knowledge acquisition.
- Immersive Simulation: Utilizing 2D pixel-art to visually represent plant health and emotions, fostering empathy and engagement.
- Learning by Doing: Allowing users to care for virtual plants in realistic ways, building practical knowledge and real-life gardening skills.
- Creative Freedom: Enabling users to create custom plants, promoting curiosity and deeper learning.

## Technology Underneath

A clean microservices based architecture, all synced to perfect harmony using RabbitMQ with modern Agentic AI and Generative AI capabilities.

### Generative AI

Verdantia uses Verdara from real time plant graphics generation. Verdara is a highly customizable command based plant graphic generation tool made for consistent plant graphic across ages and health conditions. Made using Java Spring Boot, Verdara analyzes user commands that describe specific features of the plant and renders consistent graphics.

### User Service
The User Service handles authentication using Firebase Auth and manages user profiles in a custom User DB. Upon successful login or registration, it updates user data such as display name, preferences, and progress metadata. Present on Flutter App.

### Plant Service
The Plant Service is responsible for managing the lifecycle of each plant, including growth stages, health points (HP), and visual appearance. It receives events (e.g., PlantCreated, PlantInteracted) from other services through RabbitMQ, updates plant states based on time and user actions, and persists data in the Plant DB.

### Botanica Service
The Botanica Service connects with an AI agent to generate detailed plant information, including common names, care guidelines, water and sunlight needs, common pests/diseases, and treatment suggestions. It also recommends suitable pesticides and fertilizers along with purchase links. Triggered via RabbitMQ, it stores this enriched data in the Botanica DB for use across the platform.

### Mobile App

The mobile app is based on the flutter bloc framework for native performance with code versatility. The UI has a pixelted theme that gives a retro and playful vibe to the application. Mobile app is well equipped with login/signin options using JWT auth and other security features.
