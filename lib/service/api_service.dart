import 'package:flutter/material.dart';
import 'package:http_interceptor/http/intercepted_http.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../utilities/localvariable.dart';
import 'api_helper.dart';

class ApiService {
  Map<String, String> headers = {};
  bool tokenUpdating = false;
  int timeoutDuration = 20;

  setHeaders(BuildContext context) async {
    headers.addAll({"Accept": "application/json"});
    headers.addAll({"Authorization": "Bearer ${Provider.of<AuthProvider>(context, listen: false).token}"});
  }

  //post call
  Future post(BuildContext context, String url, {params}) async {
    setHeaders(context);
    return await InterceptedHttp.build(interceptors: [])
        .post(Uri.parse(LocVar.url + url), body: params, headers: headers)
        .then((response) => ApiHelper().helper(context, response));
  }

  //post call
  Future post2(BuildContext context, String url, {params}) async {
    return await InterceptedHttp.build(interceptors: [])
        .post(Uri.parse(LocVar.url + url), body: params, headers: headers)
        .then((response) => ApiHelper().helper(context, response));
  }

//get call
  Future get(BuildContext context, String url, {params}) async {
    setHeaders(context);
    return await InterceptedHttp.build(interceptors: [])
        .get(Uri.parse(LocVar.url + url), params: params, headers: headers)
        .then((response) => ApiHelper().helper(context, response));
  }

  //get call
  Future getAllUrl(BuildContext context, String url, {params}) async {
    setHeaders(context);
    return await InterceptedHttp.build(interceptors: [])
        .get(Uri.parse(url), params: params, headers: headers)
        .then((response) => ApiHelper().helper(context, response));
  }

  //psot call
  Future postAllUrl(BuildContext context, String url, {params}) async {
    setHeaders(context);
    return await InterceptedHttp.build(interceptors: [])
        .post(Uri.parse(url), params: params, headers: headers)
        .then((response) => ApiHelper().helper(context, response));
  }
}
