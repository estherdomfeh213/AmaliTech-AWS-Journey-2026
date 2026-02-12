# Serverless Contact Form with AWS 

A serverless contact form built with AWS Lambda, API Gateway, and SES, demonstrating a fully cloud-native approach with near-zero operational cost. This project highlights event-driven architecture, serverless best practices, and cost optimization skills.


## Architecture Diagram 
![Serverless Contact Form](images/architecture-diagram.png)

## Architecture Overview
This contact form allows users to submit their **name, email, and message**, which is then sent as an email using **AWS SES**. The application is **fully serverless**, meaning no backend servers are required, ensuring **scalability, cost efficiency, and reliability**.


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