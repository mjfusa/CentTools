using System.Xml.Linq;
using System;
using System.Diagnostics;

XDocument doc = XDocument.Load(@".\AppxManifest.xml");
var ns = doc.Root.GetDefaultNamespace();
var AppExeName = doc.Descendants(XName.Get("Application", ns.NamespaceName)).First().Attribute(XName.Get("Executable")).Value;
//doc.Descendants(XName.Get("Application", ns.NamespaceName)).First().Attribute(XName.Get("Executable")).Value = "cwd.exe";
Console.WriteLine(AppExeName);
var res = Process.Start("mt.exe", "-inputresource: " + "\'" + AppExeName + "\'" + " -out:" + "\'" + AppExeName +".manifest"+ "\'");
res.WaitForExit();
Console.WriteLine(res.ExitCode);
if (res.ExitCode==31)
{
    File.Copy(@"..\..\generic.manifest", AppExeName + ".manifest");
}

//mt.exe -inputresource:"%AppExeName%" -out:"%AppExeName%.manifest"