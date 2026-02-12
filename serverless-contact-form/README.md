# Serverless Contact Form with AWS 

A serverless contact form built with AWS Lambda, API Gateway, and SES, demonstrating a fully cloud-native approach with near-zero operational cost. This project highlights event-driven architecture, serverless best practices, and cost optimization skills.


## Architecture Diagram 
![Serverless Contact Form](images/architecture-diagram.png)

## Architecture Overview
- API Gateway: Exposes a REST API endpoint for the contact form with CORS enabled for browser access.
- AWS Lambda: Processes incoming form submissions, validates input, and triggers SES to send emails.
- Amazon SES: Sends emails without the need for dedicated mail servers.
- Browser Client: Simple HTML/CSS/JS form that communicates securely with API Gateway.

## Project Structure 

```text
serverless-contact-form/
├── index.html              # Frontend contact form
├── lambda-function.js      # Backend Lambda code
├── README.md              # This documentation
├── architecture-diagram.png # System architecture
└── screenshots/           # Implementation screenshots
```


## 