# Flower Website -- Full CI/CD Pipeline

A complete DevOps project demonstrating automated deployment from
**local development → GitHub → Jenkins CI/CD → AWS EC2** using modern
tooling, best practices, and an extensible architecture.

[![GitHub](https://img.shields.io/badge/GitHub-Flower--website-blue)](https://github.com/manojvistas/Flower-website)
[![Jenkins](https://img.shields.io/badge/CI%2FCD-Jenkins-red)](https://www.jenkins.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS%20EC2-orange)](https://aws.amazon.com/ec2/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

## Table of Contents

-   Overview
-   Architecture
-   Tech Stack
-   Prerequisites
-   Project Structure
-   Getting Started
-   CI/CD Workflow
-   Docker Support
-   Troubleshooting
-   Monitoring
-   Contributing
-   License
-   Support
-   Learning Resources

## Overview

This project contains a **production-ready CI/CD pipeline** automating
the deployment process of a static website:

Local Machine → GitHub → Jenkins → AWS EC2 → Live Deployment

## Architecture

    Local Dev → GitHub → Jenkins → AWS EC2 (Nginx)

## Tech Stack

Frontend: HTML, CSS, JavaScript\
DevOps: Git, GitHub, Jenkins, SSH, Docker\
Cloud: AWS EC2, Ubuntu 22.04, Nginx

## Prerequisites

GitHub, AWS EC2, Jenkins, SSH client, Git installed.

## Project Structure

    Flower-website/
    ├── index.html
    ├── styles.css
    ├── script.js
    ├── Dockerfile
    ├── nginx.conf
    ├── Jenkinsfile
    ├── README.md
    └── .gitignore

## Getting Started

### Step 1: Local Development

Create project folder and website files.

### Step 2: Initialize Git

    git init
    git add .
    git commit -m "Initial commit"
    git remote add origin https://github.com/<YOUR_USERNAME>/Flower-website.git
    git branch -M main
    git push -u origin main

### Step 3: AWS EC2 Setup

Launch Ubuntu 22.04 → install Nginx:

    sudo apt update
    sudo apt install nginx -y

### Step 4: Jenkins Configuration

Add SSH credentials → Create Pipeline Job → Configure SCM.

## CI/CD Workflow

Push updates → Jenkins triggers → Deploys to EC2 → Nginx serves site.

## Docker Support

Build Docker image:

    docker build -t flower-website .
    docker run -d -p 8095:8095 flower-website

## Troubleshooting

Covers SSH issues, Nginx cache, port conflicts, Jenkins permissions.

## Monitoring

View logs:

    sudo tail -f /var/log/nginx/error.log

## Contributing

Fork → Branch → Commit → PR.

## License

MIT License.

## Support

Open GitHub issues or review logs.

## Learning Resources

Jenkins Docs, AWS EC2 Guide, Docker Docs, Git Workflow.
