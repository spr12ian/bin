#!/bin/bash

# No need for the snap of code on WSL Ububtu as it prefers to use Windows VS Code
sudo snap install --classic code
sudo snap install --classic go
sudo snap install hugo
sudo snap install node --classic
sudo snap install sqlitebrowser

sudo snap refresh
