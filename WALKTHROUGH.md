# Onceover Training

The purpose of this training is to educate people on how onceover works, how to set it up, and how to work around the diverse range of problems you're likely to come across when testing your Puppet code.

## How it Works

* Overview of how it works

## Basic Setup

* How to initialise and set up some basic tests and groups

## Basic Hiera

* How to get onceover to use your hiera data
* How it is used

## The Importance of Custom Facts

* Show that custom facts are often used in roles and profiles
* Show that they are also often used in hiera hierarchies and prove that we need them to have any hope of things working
* Make sure there are examples that people can use to fix and then get green tests

## The Importance of Hiera Data

* Show that many nodes will often have hiera data that is specifically required for catalog compilation
  * Note that we could just get the facts from the nodes but this would result in some very specific test config
  * Alternately we could create a custom hiera level which is often a better idea

## Mocking Functions

* How to fix a function that is not working

