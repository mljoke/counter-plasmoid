cmake_minimum_required(VERSION 3.16)

project(plasma-counter)
 
find_package(ECM 1.4.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(KF5Plasma REQUIRED)
#target_link_libraries(plasma-counter KF6::Plasma KF6::PlasmaQuick)
# TODO: adapt "org.kde.plasma" here & elsewhere if needed (see README)
plasma_install_package(package org.kde.plasma.counter)
