# Project 2: Ceph Fault Injection

## Important Dates

**Due:** Monday 10/29.

## Overview

The project introduces you to the fundamentals of fault injection under a distributed system, namely Ceph. Please work in groups of size three unless impossible.

## Details

### Step One: Read and Understand

We will run this project as we run some types of research endeavors. What we do sometimes is as follows. We find a paper that we think is really interesting. Then, we read it carefully! Then, we try to reproduce some of the work within the paper, to get a feel for how everything works. Then, if we're clever, we even come up with a way to improve upon what the previous authors have done, thus adding to the state of the art.

In this project, you'll build on work we've done here at Wisconsin. Specifically, you'll read [this paper](http://research.cs.wisc.edu/adsl/Publications/cords-tos17.pdf) on a fault-injection approach we've built called CORDS. And thus, we have step one of this project. Read the paper carefully with great attention to detail.

### Step Two: Understand the Existing Software

The kind authors of this paper have done more than just give you a paper description of what they did. Rather, they have given you the software they used! How kind of them. Indeed, [here](http://research.cs.wisc.edu/adsl/Software/cords/) is a link to said software.

And now we have step two of the project defined. Download the software and figure out how it all works.

### Step Three: Apply the Approach To Ceph

And now, the hard part: applying the tool to Ceph. Ceph has two underlying local storage engines, FileStore and BlueStore. With FileStore, the CORDS tool may be more easy to use; with BlueStore, it may be more relevant, because BlueStore is the way Ceph is going in the future. Thus, you already have a problem common in research: do what is easy, or what is important? If the former, it will (probably) be easier to use CORDS to do the work; if the latter, you'll have to adapt the tool to work with BlueStore to get results, but the results will be of more interest. And thus your first choice, as researchers: which path to follow? Of course, you could choose both, just to be safe.

Getting such a tool to run will be hard, no matter what, because you have to understand details of things like how to create workloads that exercise the right I/O paths, and how to flip bits in various on-disk fields, all of which are very system specific. Thus, you'll have to learn a lot about how Ceph stores data on disk to do this study well. Thus, start learning!

### Step Four: Actual Research

A really good version of this assignment will do a thorough analysis of Ceph, using the CORDS paper as a guide for the types of results one would expect to see. An even better version would add to the state of the art of system testing, adding some new way to inject faults that is either faster, more thorough, or (in general) better than what CORDS does. Not all groups will get to this, but if you do, you will be celebrated.

## Machines To Use

For this project, you might want to continue to use Google Cloud. However, a local set up of some kind would be fine, as performance doesn't matter. Really, a single machine should be enough to do this testing. So don't waste money by running on many machines.

## Questions?

It is generally OK to ask questions on Piazza - and, for other students to answer them - on Piazza. Don't worry! Unless you are just giving all of your code to others, it is fine to share and collaborate to help out others in class.

We will also schedule a session with the two lead authors of this work to answer your questions, so the more you know - and the sooner you know it - the better.

## Handing It In

To turn this project in, you'll just meet with me and present your results. You'll also turn in a short (1-2 page) writeup of what you did. I'll give a little more detail in class as the deadline approaches.

You will also place what you have done into one partner's handin directory. From the other partners' handin directories, create soft links to this directory.