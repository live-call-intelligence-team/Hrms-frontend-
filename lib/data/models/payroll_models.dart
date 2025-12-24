class SalaryStructure {
  final int id;
  final String name;
  final double basicSalary;
  final int totalComponents;
  final double monthlyGross;
  final List<SalaryComponent> earnings;
  final List<SalaryComponent> deductions;

  SalaryStructure({
    required this.id,
    required this.name,
    required this.basicSalary,
    required this.totalComponents,
    required this.monthlyGross,
    required this.earnings,
    required this.deductions,
  });

  factory SalaryStructure.fromJson(Map<String, dynamic> json) {
    return SalaryStructure(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      basicSalary: (json['basic_salary'] ?? 0).toDouble(),
      totalComponents: json['total_components'] ?? 0,
      monthlyGross: (json['monthly_gross'] ?? 0).toDouble(),
      earnings: (json['earnings'] as List?)
              ?.map((e) => SalaryComponent.fromJson(e))
              .toList() ??
          [],
      deductions: (json['deductions'] as List?)
              ?.map((e) => SalaryComponent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class SalaryComponent {
  final String name;
  final double amount;
  final String type; // Fixed, Formula

  SalaryComponent({required this.name, required this.amount, required this.type});

  factory SalaryComponent.fromJson(Map<String, dynamic> json) {
    return SalaryComponent(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'Fixed',
    );
  }
}

class PayrollEntry {
  final int id;
  final int employeeId;
  final String employeeName;
  final String department;
  final double basicSalary;
  final double grossSalary;
  final double netSalary;
  final String status; // Paid, Pending, Draft
  final String month; // YYYY-MM

  PayrollEntry({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.basicSalary,
    required this.grossSalary,
    required this.netSalary,
    required this.status,
    required this.month,
  });

  factory PayrollEntry.fromJson(Map<String, dynamic> json) {
    return PayrollEntry(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      employeeName: json['employee_name'] ?? 'Unknown',
      department: json['department'] ?? '',
       basicSalary: (json['basic_salary'] ?? 0).toDouble(),
      grossSalary: (json['gross_salary'] ?? 0).toDouble(),
      netSalary: (json['net_salary'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      month: json['month'] ?? '',
    );
  }
}

class Payslip {
  final int id;
  final String monthYear;
  final CompanyInfo companyInfo;
  final PayrollEmployeeInfo employeeInfo;
  final List<SalaryComponent> earnings;
  final List<SalaryComponent> deductions;
  final double totalEarnings;
  final double totalDeductions;
  final double netSalary;

  Payslip({
    required this.id,
    required this.monthYear,
    required this.companyInfo,
    required this.employeeInfo,
    required this.earnings,
    required this.deductions,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netSalary,
  });

  factory Payslip.fromJson(Map<String, dynamic> json) {
    return Payslip(
      id: json['id'] ?? 0,
      monthYear: json['month_year'] ?? '',
      companyInfo: CompanyInfo.fromJson(json['company_info'] ?? {}),
      employeeInfo: PayrollEmployeeInfo.fromJson(json['employee_info'] ?? {}),
      earnings: (json['earnings'] as List?)
              ?.map((e) => SalaryComponent.fromJson(e))
              .toList() ?? [],
      deductions: (json['deductions'] as List?)
              ?.map((e) => SalaryComponent.fromJson(e))
              .toList() ?? [],
       totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
       totalDeductions: (json['total_deductions'] ?? 0).toDouble(),
       netSalary: (json['net_salary'] ?? 0).toDouble(),
    );
  }
}

class CompanyInfo {
    final String name;
    final String address;
    final String logoUrl;
    
    CompanyInfo({required this.name, required this.address, required this.logoUrl});
    
    factory CompanyInfo.fromJson(Map<String, dynamic> json) {
        return CompanyInfo(
            name: json['name'] ?? 'HRMS Company',
            address: json['address'] ?? '123 Business Rd, Tech City',
            logoUrl: json['logo_url'] ?? '',
        );
    }
}

class PayrollEmployeeInfo {
    final String name;
    final String designation;
    final String department;
    final String employeeId;
    final String joiningDate;
    
    PayrollEmployeeInfo({
        required this.name,
        required this.designation,
        required this.department,
        required this.employeeId,
        required this.joiningDate,
    });
    
     factory PayrollEmployeeInfo.fromJson(Map<String, dynamic> json) {
        return PayrollEmployeeInfo(
            name: json['name'] ?? '',
            designation: json['designation'] ?? '',
            department: json['department'] ?? '',
            employeeId: json['employee_id'] ?? '',
            joiningDate: json['joining_date'] ?? '',
        );
    }
}

class PayslipStat {
    final double totalEarnedYear;
    final double avgMonthly;
    final double highestMonth;
    
    PayslipStat({required this.totalEarnedYear, required this.avgMonthly, required this.highestMonth});
    
    factory PayslipStat.fromJson(Map<String, dynamic> json) {
        return PayslipStat(
            totalEarnedYear: (json['total_earned_year'] ?? 0).toDouble(),
            avgMonthly: (json['avg_monthly'] ?? 0).toDouble(),
            highestMonth: (json['highest_month'] ?? 0).toDouble(),
        );
    }
}

class PayrollSummary {
    final int totalEmployees;
    final double totalGross;
    final double totalNet;
    
    PayrollSummary({required this.totalEmployees, required this.totalGross, required this.totalNet});
    
     factory PayrollSummary.fromJson(Map<String, dynamic> json) {
        return PayrollSummary(
            totalEmployees: json['total_employees'] ?? 0,
            totalGross: (json['total_gross'] ?? 0).toDouble(),
            totalNet: (json['total_net'] ?? 0).toDouble(),
        );
    }
}
