

import 'package:flutter/material.dart';
import 'package:niion/pojo/RidePojo.dart';

import 'RidesDatabase.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  List<NotificationPojo> list = [];
  List<NotificationPojo> listAll = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNotification();
  }

  Future fetchNotification() async {
    list = await RidesDatabase.instance.getAllNotificationList();
    if (list.length > 25) {
      for (int i = 25; i < list.length; i++) {
        print("id ${list[i].id}");
        RidesDatabase.instance.deleteNotification(list[i].id!);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Color(0xFF030112),
        automaticallyImplyLeading: false,
        title: Text(
          'Notification History',
          style: FlutterFlowTheme.of(context).title1.override(
                fontFamily: 'Poppins',
                color: Color(0xFFEDED16),
              ),
        ),
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFFEDED16),
              size: 35,
            )),
        centerTitle: false,
        elevation: 2,
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          itemCount: list.length > 25 ? 25 : list.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, int index) {
            DateTime dateTime =
                DateTime.fromMillisecondsSinceEpoch(list[index].createdTime!);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 3,
                      color: Color(0x430F1113),
                      offset: Offset(0, 1),
                    )
                  ],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.date_range,
                            color: Colors.black,
                            size: 20,
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 0, 0),
                            child: Text(
                              DateFormat('dd MMM,yyyy').format(dateTime),
                              style: FlutterFlowTheme.of(context)
                                  .subtitle2
                                  .override(
                                    fontFamily: 'Poppins',
                                    color: Color(0xFF030112),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(5, 4, 0, 0),
                            child: Text(
                              DateFormat('hh:mm a').format(dateTime),
                              style: FlutterFlowTheme.of(context)
                                  .subtitle2
                                  .override(
                                    fontFamily: 'Poppins',
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(5, 5, 5, 5),
                      child: Text(
                        list[index].message ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: FlutterFlowTheme.of(context).subtitle2.override(
                              fontFamily: 'Poppins',
                              color: Color(0xFF030112),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    ));
  }
}
