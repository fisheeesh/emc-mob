import 'dart:io';
import 'package:emc_mob/models/employee_model.dart';
import 'package:emc_mob/services/employee_service.dart';
import 'package:flutter/material.dart';

class EmployeeProvider with ChangeNotifier {
  Employee? _employee;
  bool _isLoading = false;
  bool _isUpdating = false;
  String? _errorMessage;

  Employee? get employee => _employee;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  final EmployeeService _employeeService = EmployeeService();

  Future<void> fetchEmployeeData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _employeeService.getEmployeeData();

      if (response['data'] != null) {
        _employee = Employee.fromJson(response['data']);
        _errorMessage = null;
      } else {
        _errorMessage = 'No employee data found';
      }
    } catch (e) {
      _errorMessage = e.toString();
      _employee = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateEmployeeData({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String gender,
    required DateTime birthdate,
    File? avatarFile,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _employeeService.updateEmployeeData(
        id: id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        gender: gender,
        birthdate: birthdate,
        avatarFile: avatarFile,
      );

      if (response['message'] != null) {
        /// Refresh employee data after successful update
        await fetchEmployeeData();
        _errorMessage = null;
        return true;
      } else {
        _errorMessage = 'Failed to update employee data';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearEmployeeData() {
    _employee = null;
    _errorMessage = null;
    notifyListeners();
  }
}