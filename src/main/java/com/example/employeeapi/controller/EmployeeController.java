package com.example.employeeapi.controller;

import com.example.employeeapi.model.Employee;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.PostConstruct;
import org.springframework.web.bind.annotation.*;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/employees")
@Tag(
    name = "Employee API",
    description = "CRUD Operations for Employees"
)
public class EmployeeController {

    private final Map<Long, Employee> employees = new HashMap<>();

    @PostConstruct
    public void initData() {

        employees.put(
                1L,
                new Employee(
                        1L,
                        "John",
                        "Engineering",
                        85000
                ));

        employees.put(
                2L,
                new Employee(
                        2L,
                        "Mary",
                        "HR",
                        65000
                ));
    }

    @GetMapping
    @Operation(summary = "Get all employees")
    public Collection<Employee> getAllEmployees() {
        return employees.values();
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get employee by ID")
    public Employee getEmployee(@PathVariable Long id) {
        return employees.get(id);
    }

    @PostMapping
    @Operation(summary = "Create employee")
    public Employee createEmployee(
            @RequestBody Employee employee) {

        employees.put(
                employee.getId(),
                employee);

        return employee;
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update employee")
    public Employee updateEmployee(
            @PathVariable Long id,
            @RequestBody Employee employee) {

        employee.setId(id);

        employees.put(id, employee);

        return employee;
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete employee")
    public String deleteEmployee(
            @PathVariable Long id) {

        employees.remove(id);

        return "Employee deleted successfully";
    }
}