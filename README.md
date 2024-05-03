# FEUP-reUSE Development Report

Welcome to the documentation pages of the FEUP-reUSE application!

You can find here details about the app, from a high-level vision to low-level implementation decisions, a kind of Software Development Report, organized by type of activities: 

* [Business modeling](#Business-Modelling) 
  * [Product Vision](#Product-Vision)
  * [Features and Assumptions](#Features-and-Assumptions)
  * [Elevator Pitch](#Elevator-pitch)
* [Requirements](#Requirements)
  * [User stories](/docs/UserStories.md)
  * [Domain model](#Domain-model)
* [Architecture and Design](#Architecture-And-Design)
  * [Logical architecture](#Logical-Architecture)
  * [Physical architecture](#Physical-Architecture)
  * [Vertical prototype](#Vertical-Prototype)
* [Project management](#Project-Management)

Contributions are expected to be made exclusively by the initial team, but we may open them to the community, after the course, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us!

Thank you!

**Project Team**:

- Antero Morgado (up202204971@fe.up.pt); 
- David Gustavo (up202208654@fe.up.pt);
- Diogo Vieira (up202208723@fe.up.pt);
- Leonardo Teixeira (up202208726@fe.up.pt);
- João Torres (up202205576@fe.up.pt).


---
## Business Modelling

### Product Vision

FEUP-reUSE is an innovative mobile application aimed at revolutionizing the trading experience, specifically tailored to the vibrant community of the Faculty of Engineering at the University of Porto (FEUP).

Catering to students, faculty members, and staff alike, FEUP-reUSE provides an ideal platform for connecting with potential trade partners within the FEUP community. Whether you're seeking to exchange books, clothing, home appliances, electronics, or educational materials, FEUP-reUSE offers a user-friendly interface reminiscent of Instagram, streamlining the trading process and making it both effortless and enjoyable.

It's worth highlighting that FEUP-reUSE operates solely on a donation basis, ensuring that transactions involve no monetary exchange. This fosters a spirit of generosity and community within FEUP, further enhancing the app's appeal and promoting a collaborative trading environment.


### Features and Assumptions

- **Publication System**: Easily create and share posts featuring photos and detailed descriptions of items for trade in the following categories: Books, Clothing, Home Appliances, Electronics, Educational Materials and Miscellaneous.
- **Chat Functionality**: Engage in seamless negotiations and trades with other users through our integrated chat feature, facilitating smooth communication and deal-making. When a user shows interest in an item, they can open a chat with the seller, without the item becoming reserved. It remains the responsibility of the individuals involved to manage the availability of the item during conversation.
- **Rating System**: Rate and review trade partners to share your trading experience and help build a trustworthy community.  

### Elevator Pitch

Welcome to FEUP-reUSE, the game-changing mobile app designed to transform the trading experience within the vibrant community of the Faculty of Engineering at the University of Porto (FEUP).

Imagine a platform where students, faculty, and staff can effortlessly connect to trade items ranging from textbooks to electronics, all in a seamless and enjoyable manner. With FEUP-reUSE, users can easily create and share posts featuring detailed descriptions and photos of their items, browse through a variety of categories, and engage in smooth negotiations through integrated chat functionality.

But what sets FEUP-reUSE apart is its commitment to fostering a spirit of generosity and community. Operating solely on a donation basis, FEUP-reUSE ensures that transactions involve no monetary exchange, promoting a collaborative environment where users can trade with confidence. Join us in revolutionizing the way we trade and connect within the FEUP community with FEUP-reUSE!


## Requirements

**The <u>User Stories</u> can be found [Here](https://github.com/FEUP-LEIC-ES-2023-24/2LEIC02T1/issues).**


**User interface mockups**.

You can view the detailed design in Figma by clicking [here](https://www.figma.com/embed?embed_host=share&url=https%3A%2F%2Fwww.figma.com%2Ffile%2FwaG9rfnHrQoSPZGIzqWNK3%2FUntitled%3Ftype%3Ddesign%26node-id%3D0%253A1%26mode%3Ddesign%26t%3DCNXMsZtoZEVx7IbM-1).

![Mockup](/images/FEUP-reUSE%20mockup.png)


### Domain model

A user profile includes the user's name, email address, phone number, and profile picture. Each user can publish multiple products, with each product categorized accordingly. A published product available for trade is termed a "Post," which requires a description and image. Each post is associated with a status indicating its availability. Additionally, users can engage in multiple chats with other traders to facilitate and expedite trades.

![DomainModel](/images/DomainModel.png)

## Architecture and Design


### Logical architecture

In this subsection, we document the high-level logical structure of the code (Logical View), using a UML diagram with logical packages.

Our system has three main components:

-User Interface:
The UI component is responsible for user interactions. It communicates user input to the logic component for processing.

-Logic:
The Logic component serves as a mediator between the UI and the database and handles authentication, chat and others.

-Database:
Firebase serves as the backend storage solution, storing user data securely and facilitating real-time data synchronization.

![LogicalView](/images/LogicalArchitecture.png)

### Physical architecture

In this subsection, we provide an overview of the physical structure of the Feup-reUSE software system using a UML deployment diagram (Deployment View).

Feup-reUSE is deployed on the user's smartphone. The application securely stores login data and other user information utilizing Firebase, a robust backend platform. This ensures seamless authentication and data management functionalities.

Moreover, Feup-reUSE has access to the local files stored on the user's smartphone. This access enables the application to upload photos for creating posts and to update the user's profile picture.

![DeploymentView](/images/DeploymentView.png)

### Vertical prototype
For the Vertical Prototype, we focused on implementing the search user functionality. This feature was chosen due to its simplicity and its seamless integration between the backend, frontend, and Firebase.

![VerticalPrototype](/images/preview.gif)

## Project management
You can find below information and references related with the project management in our team: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/59);
* Release management: 
- [Iteration 0](#iteration-0)
- [Iteration 1](#iteration-1)
- [Iteration 2]()
- [Iteration 3]()


### Iteration planning and retrospectives:

## Iteration 0

> ## Plans:
> ### Development Board
> <p>Start:</p>
> <img src="/images/BacklogIteration0.png">
> <br>
> <p>End:</p>
> <img src="/images/BacklogIteration0.png">
>
> ### Retrospective
> <p>This iteration does not add any functionalities to the application.</p>
 
## Iteration 1

> ## Plans:
> ### Development Board
> <p>Start:</p>
> <img src="/images/BacklogIteration1Start.png">
> <br>
> <p>End:</p>
> <img src="/images/BacklogIteration1End.png">
>
> ### Retrospective
> <p>Our team demonstrated exceptional collaboration, effectively delivering key features and meeting sprint goals. Communication was clear and frequent, ensuring everyone stayed informed and aligned. These strengths contributed to the successful completion of tasks and the overall progress of the project.</p>
>
> ## Start
> <p>Integrate design templates or frameworks into our development process to streamline the design phase and ensure consistency across our products. By adopting pre-built design elements or templates, we can expedite the design process while maintaining a high standard of visual appeal and usability.</p>
>
> ## Continue
> <p>Continue maintaining the exceptional level of collaboration within the team, ensuring clear communication and alignment. Additionally, focus on effectively delivering key features and meeting sprint goals.</p>
> 
>
> ## Stop
> <p>Avoid neglecting the quality of designs and user experience. It's crucial to prioritize addressing these aspects in future sprints to ensure the success and satisfaction of our users.</p>
> 
> 


## Iteration 2

> ## Plans:
> ### Development Board
> <p>Start:</p>
> <img src="/images/BacklogIteration2Start.png">
> <br>
> <p>End:</p>
> <img src="/images/BacklogIteration2End.png">
>
> ### Retrospective
> <p>During this sprint, our team showcased remarkable adaptability, swiftly adjusting to unexpected challenges and maintaining a steady pace towards our objectives. Communication remained transparent and consistent, fostering a sense of unity and purpose among team members. These strengths were instrumental in overcoming obstacles and driving the project forward with efficiency and precision.</p>
>
> ## Start
> 
As we review our sprint, it's clear that our team displayed admirable collaboration and met our objectives. However, there are areas where our processes require refinement. We need to prioritize "smoothing edges," emphasizing the importance of attention to detail. This means ensuring that even the smallest details are functioning effectively in our project. 
>
> ## Continue
> <p>Continue upholding the exceptional level of collaboration within the team, ensuring both clear communication and alignment. Additionally, concentrate on efficiently delivering key features and meeting sprint goals.</p>
> 
>
> ## Stop
> <p>Let's ensure we don't overlook the user experience. It's vital to prioritize enhancing this aspect in future sprints to ensure our users are not just satisfied, but delighted with our product.</p>
> 
> 
 

 
