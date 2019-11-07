import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yodel/src/common/widgets/index.dart';
import 'package:yodel/src/home/index.dart';
import 'package:yodel/src/shift/index.dart';
import 'package:yodel/src/theme/themes.dart';

class CreateShiftScreen extends StatefulWidget {
  @override
  _CreateShiftScreenState createState() => _CreateShiftScreenState();
}

class _CreateShiftScreenState extends State<CreateShiftScreen>
    with PostBuildActionMixin {
  CreateShiftBloc _bloc;
  CreateShiftStep1FormBloc _step1FormBloc;
  CreateShiftStep2FormBloc _step2FormBloc;
  CreateShiftStep3FormBloc _step3FormBloc;

  @override
  void initState() {
    final companyBloc = BlocProvider.of<CompanyBloc>(context);
    companyBloc.add(Fetch());

    _bloc = CreateShiftBloc(
      refresherBloc: BlocProvider.of<ShiftsSyncBloc>(context),
    );
    _step1FormBloc = CreateShiftStep1FormBloc();
    _step2FormBloc = CreateShiftStep2FormBloc(
      companyBloc: companyBloc,
      step1FormBloc: _step1FormBloc,
    );

    _step3FormBloc = CreateShiftStep3FormBloc(
      worker: _bloc.currentWorker,
      step1FormBloc: _step1FormBloc,
    );

    super.initState();
  }

  @override
  void dispose() {
    _step1FormBloc.dispose();
    _step2FormBloc.dispose();
    _step3FormBloc.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CreateShiftBloc>.value(
      value: _bloc,
      child: StreamBuilder<CreateShiftSteps>(
        initialData: _bloc.initialStep,
        stream: _bloc.steps,
        builder: (context, snapshot) {
          String title = snapshot.data.currentStep > 1
              ? _step1FormBloc.currentName
              : "New Shift";
          return WillPopScope(
            onWillPop: () async {
              if (snapshot.data.canMoveBack()) {
                _bloc.add(CreateShiftMoveToStep(
                  step: snapshot.data.step - 1,
                ));
              } else {
                final cancel = await showConfirmDialog(context,
                    title: "Are you sure you want to cancel?");

                if (cancel) {
                  Navigator.pop(context);
                }
              }
              return false;
            },
            child: SafeArea(
              child: KeyboardDismissable(
                child: Stack(
                  children: <Widget>[
                    Scaffold(
                      backgroundColor: YodelTheme.lightPaleGrey,
                      appBar: AppBar(
                        centerTitle: true,
                        leading: OverflowBox(
                          maxWidth: 90.0,
                          child: NavbarButton(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text("Back"),
                              onPressed: () {
                                if (snapshot.data.canMoveBack()) {
                                  _bloc.add(CreateShiftMoveToStep(
                                    step: snapshot.data.step - 1,
                                  ));
                                } else {
                                  Navigator.pop(context);
                                }
                              }),
                        ),
                        actions: <Widget>[
                          NavbarButton(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                "Cancel",
                              ),
                              onPressed: () async {
                                final cancel = await showConfirmDialog(context,
                                    title: "Are you sure you want to cancel?");

                                if (cancel) {
                                  Navigator.popUntil(
                                      context, ModalRoute.withName("/home"));
                                }
                              }),
                        ],
                        automaticallyImplyLeading: false,
                        title: Text(title),
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(70),
                          child: Container(
                            color: YodelTheme.darkGreyBlue,
                            height: 80,
                            child: YodelStepper(
                              currentStep: snapshot.data.currentStep - 1,
                              activeColor: YodelTheme.amber,
                              defaultColor: YodelTheme.lightGreyBlue,
                              disabledColor: YodelTheme.lightGreyBlue,
                              iconColor: YodelTheme.darkGreyBlue,
                              lineHeight: 2,
                              type: StepperType.horizontal,
                              labelStyle: YodelTheme.metaDefaultInactive,
                              activeLabelStyle: YodelTheme.metaRegularManage,
                              onStepTapped: (step) {
                                if (!snapshot.data.isCurrent(step + 1) &&
                                    snapshot.data.canMoveTo(step + 1)) {
                                  _bloc.add(CreateShiftMoveToStep(
                                    step: step + 1,
                                  ));
                                }
                              },
                              steps: <Step>[
                                Step(
                                  isActive: snapshot.data.isCurrent(1) ||
                                      snapshot.data.canMoveTo(1),
                                  state: snapshot.data.isCurrent(1)
                                      ? StepState.indexed
                                      : snapshot.data.canMoveTo(1) &&
                                              snapshot.data.step >= 1
                                          ? StepState.complete
                                          : StepState.disabled,
                                  title: Text(
                                    'Details',
                                  ),
                                  content: Container(),
                                ),
                                Step(
                                  isActive: snapshot.data.isCurrent(2) ||
                                      snapshot.data.canMoveTo(2),
                                  state: snapshot.data.isCurrent(2)
                                      ? StepState.indexed
                                      : snapshot.data.canMoveTo(2) &&
                                              snapshot.data.step >= 2
                                          ? StepState.complete
                                          : StepState.disabled,
                                  title: Text(
                                    'Requirements',
                                  ),
                                  content: Container(),
                                ),
                                Step(
                                  isActive: snapshot.data.isCurrent(3) ||
                                      snapshot.data.canMoveTo(3),
                                  state: snapshot.data.isCurrent(3)
                                      ? StepState.indexed
                                      : snapshot.data.canMoveTo(3) &&
                                              snapshot.data.step >= 3
                                          ? StepState.complete
                                          : StepState.disabled,
                                  title: Text(
                                    'Approval',
                                  ),
                                  content: Container(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      body: BlocListener(
                        bloc: _bloc,
                        listener: (context, CreateShiftState state) {
                          if (state is CreateShiftStepState) {
                            if (state.canNavigate) {
                              switch (state.currentStep) {
                                case 4:
                                  _bloc.add(ResetShiftStep());
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlocProvider<CreateShiftBloc>.value(
                                                value: _bloc,
                                                child:
                                                    CreateShiftStep4Screen()),
                                      ));

                                  break;
                              }
                            }
                          }
                        },
                        child: BlocBuilder(
                          bloc: _bloc,
                          builder:
                              (BuildContext context, CreateShiftState state) {
                            if (state is CreateShiftStepState) {
                              switch (state.currentStep) {
                                case 2:
                                  return CreateShiftStep2Form(
                                    formBloc: _step2FormBloc,
                                  );
                                case 3:
                                  return CreateShiftStep3Form(
                                    formBloc: _step3FormBloc,
                                  );
                                default:
                                  return CreateShiftStep1Form(
                                    formBloc: _step1FormBloc,
                                  );
                              }
                            }
                            return LoadingIndicator();
                          },
                        ),
                      ),
                    ),
                    BlocBuilder(
                      bloc: _bloc,
                      builder: (BuildContext context, CreateShiftState state) {
                        if (state is CreateShiftStepState) {
                          switch (state.currentStep) {
                            case 2:
                              return _Step2FormButton(
                                formBloc: _step2FormBloc,
                              );
                            case 3:
                              return _Step3FormButton(formBloc: _step3FormBloc);
                            default:
                              return _Step1FormButton(formBloc: _step1FormBloc);
                          }
                        }
                        return LoadingIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Step1FormButton extends StatelessWidget {
  final CreateShiftStep1FormBloc formBloc;

  const _Step1FormButton({
    Key key,
    @required this.formBloc,
  })  : assert(formBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateShiftBloc>(context);

    return StreamBuilder<bool>(
        initialData: formBloc.valid,
        stream: formBloc.isValid,
        builder: (context, snapshot) {
          final double height = snapshot.hasData && !snapshot.data ? 130 : 100;
          return Positioned(
            height: height,
            width: MediaQuery.of(context).size.width,
            bottom: 0,
            child: Material(
              child: Container(
                height: height,
                color: YodelTheme.darkGreyBlue,
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (snapshot.hasData && !snapshot.data)
                      Text(
                        "Complete required field to proceed",
                        style: YodelTheme.metaWhite,
                      ),
                    if (snapshot.hasData && !snapshot.data)
                      Container(
                        height: 8,
                      ),
                    ProgressButton(
                      child: Text("Next",
                          style: snapshot.hasData && snapshot.data
                              ? YodelTheme.bodyStrong
                              : YodelTheme.bodyWhite),
                      color: YodelTheme.amber,
                      isLoading: false,
                      width: double.infinity,
                      onPressed: snapshot.hasData && snapshot.data
                          ? () {
                              _bloc.add(UpdateShiftDetails(
                                description: formBloc.currentDescription,
                                endDate: formBloc.currentEndDate,
                                location: formBloc.currentLocation,
                                name: formBloc.currentName,
                                startDate: formBloc.currentStartDate,
                              ));
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class _Step2FormButton extends StatelessWidget with PostBuildActionMixin {
  final CreateShiftStep2FormBloc formBloc;
  const _Step2FormButton({
    Key key,
    @required this.formBloc,
  })  : assert(formBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateShiftBloc>(context);

    return StreamBuilder<bool>(
        initialData: formBloc.valid,
        stream: formBloc.isValid,
        builder: (context, snapshot) {
          return StreamBuilder<String>(
              stream: formBloc.eligibility,
              builder: (context, snapshot1) {
                double height = 100;
                bool requiresSeparator = false;

                Widget child;

                if (snapshot1.hasData || snapshot1.hasError) {
                  height = 130;
                  requiresSeparator = true;
                } else if (snapshot.hasData && !snapshot.data) {
                  height = 120;
                  requiresSeparator = true;
                } else {
                  height = 100;
                  requiresSeparator = false;
                }

                if (snapshot1.hasData) {
                  child = Text(snapshot1.data, style: YodelTheme.metaRegular);
                }

                if (snapshot1.hasError) {
                  child = Text(snapshot1.error.toString(),
                      style: YodelTheme.errorText);
                }

                return Positioned(
                  height: height,
                  width: MediaQuery.of(context).size.width,
                  bottom: 0,
                  child: Material(
                    child: Container(
                      height: height,
                      color: YodelTheme.darkGreyBlue,
                      alignment: Alignment.bottomCenter,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            child: child,
                          ),
                          if (snapshot.hasData && !snapshot.data)
                            Text(
                              "Complete required field to proceed",
                              style: YodelTheme.metaWhite,
                            ),
                          if (requiresSeparator)
                            Container(
                              height: 8,
                            ),
                          StreamBuilder<bool>(
                            initialData: false,
                            stream: formBloc.isValidating,
                            builder: (context, snapshot1) {
                              return ProgressButton(
                                child: Text("Next",
                                    style: snapshot.hasData && snapshot.data
                                        ? YodelTheme.bodyStrong
                                        : YodelTheme.bodyWhite),
                                color: YodelTheme.amber,
                                isLoading: snapshot1.data,
                                width: double.infinity,
                                onPressed: snapshot.hasData && snapshot.data
                                    ? () async {
                                        bool hasSkillsNotSelectedConfirmed =
                                            formBloc.selectedSkills.length > 0;

                                        if (!hasSkillsNotSelectedConfirmed) {
                                          hasSkillsNotSelectedConfirmed =
                                              await showConfirmDialog(context,
                                                  title:
                                                      "You have selected no skills for this shift, this request will be sent out to ALL available employees. Do you wish to continue?");
                                        }

                                        if (hasSkillsNotSelectedConfirmed) {
                                          final isValid = await formBloc
                                              .hasEnoughEligibleWorkers();
                                          if (isValid) {
                                            _bloc.add(
                                                UpdatePeopleRequirements(
                                              headCount: formBloc
                                                  .currentHeadCountRequired,
                                              role: formBloc.selectedRole,
                                              sites: formBloc.selectedSites,
                                              skills: formBloc.selectedSkills,
                                              eligibleWorkers: formBloc
                                                  .eligibleWorkers.value,
                                            ));
                                          }
                                        }
                                      }
                                    : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }
}

class _Step3FormButton extends StatelessWidget {
  final CreateShiftStep3FormBloc formBloc;

  const _Step3FormButton({
    Key key,
    @required this.formBloc,
  })  : assert(formBloc != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<CreateShiftBloc>(context);
    final double height = 100;
    return StreamBuilder<bool>(
        initialData: formBloc.valid,
        stream: formBloc.isValid,
        builder: (context, snapshot) {
          return Positioned(
            height: height,
            width: MediaQuery.of(context).size.width,
            bottom: 0,
            child: Container(
              height: height,
              color: YodelTheme.darkGreyBlue,
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(16),
              child: ProgressButton(
                child: Text("Review Shift",
                    style: snapshot.hasData && snapshot.data
                        ? YodelTheme.bodyStrong
                        : YodelTheme.bodyWhite),
                color: YodelTheme.amber,
                isLoading: false,
                width: double.infinity,
                onPressed: snapshot.hasData && snapshot.data
                    ? () {
                        _bloc.add(UpdateApprovalRequirements(
                          mode: formBloc.selectedMode,
                          approvalPrivacyMode:
                              formBloc.selectedApprovalPrivacyMode,
                          workers: formBloc.selectedWorkers,
                        ));
                      }
                    : null,
              ),
            ),
          );
        });
  }
}
