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
Draft a small text to help you quickly introduce and describe your product in a short time (lift travel time ~90 seconds) and a few words (~800 characters), a technique usually known as elevator pitch.

Take a look at the following links to learn some techniques:
* [Crafting an Elevator Pitch](https://www.mindtools.com/pages/article/elevator-pitch.htm)
* [The Best Elevator Pitch Examples, Templates, and Tactics - A Guide to Writing an Unforgettable Elevator Speech, by strategypeak.com](https://strategypeak.com/elevator-pitch-examples/)
* [Top 7 Killer Elevator Pitch Examples, by toggl.com](https://blog.toggl.com/elevator-pitch-examples/)


## Requirements

In this section, you should describe all kinds of requirements for your module: functional and non-functional requirements.[????????]


**User interface mockups**.
After the user story text, you should add a draft of the corresponding user interfaces, a simple mockup or draft, if applicable.



### Domain model

To better understand the context of the software system, it is very useful to have a simple UML class diagram with all the key concepts (names, attributes) and relationships involved of the problem domain addressed by your module. 
Also provide a short textual description of each concept (domain class). 

Example:
 <p align="center" justify="center">
  <img src="https://github.com/FEUP-LEIC-ES-2022-23/templates/blob/main/images/DomainModel.png"/>
</p>


## Architecture and Design
The architecture of a software system encompasses the set of key decisions about its overall organization. 

A well written architecture document is brief but reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the overall components of the project and their interrelations. You should also describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.

### Logical architecture

![LogicalView](/images/LogicalArchitecture.png)

### Physical architecture


![DeploymentView](/images/PhysicalArchitecture.png)

### Vertical prototype
To help on validating all the architectural, design and technological decisions made, we usually implement a vertical prototype, a thin vertical slice of the system integrating as much technologies we can.

In this subsection please describe which feature, or part of it, you have implemented, and how, together with a snapshot of the user interface, if applicable.

At this phase, instead of a complete user story, you can simply implement a small part of a feature that demonstrates thay you can use the technology, for example, show a screen with the app credits (name and authors).


## Project management
Software project management is the art and science of planning and leading software projects, in which software projects are planned, implemented, monitored and controlled.

In the context of ESOF, we recommend each team to adopt a set of project management practices and tools capable of registering tasks, assigning tasks to team members, adding estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Common practices of managing iterative software development are: backlog management, release management, estimation, iteration planning, iteration development, acceptance tests, and retrospectives.

You can find below information and references related with the project management in our team: 

* Backlog management: Product backlog and Sprint backlog in a [Github Projects board](https://github.com/orgs/FEUP-LEIC-ES-2023-24/projects/64);
* Release management: [v0](#), v1, v2, v3, ...;
* Sprint planning and retrospectives: 
  * plans: screenshots of Github Projects board at begin and end of each iteration;
  * retrospectives: meeting notes in a document in the repository;
 

