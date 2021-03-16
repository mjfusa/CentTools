using System.Xml.Linq;

XDocument doc = XDocument.Load(@"files\AppxManifest.xml");
var ns = doc.Root.GetDefaultNamespace();
var AppExeName = doc.Descendants(XName.Get("Application", ns.NamespaceName)).First().Attribute(XName.Get("Executable")).Value;
doc.Descendants(XName.Get("Application", ns.NamespaceName)).First().Attribute(XName.Get("Executable")).Value = "cwd.exe";
Console.WriteLine(AppExeName);
doc.Save(@"files\AppxManifest1.xml");
using (TextWriter writer = File.CreateText(@"files\cmdline.txt"))
{
    //cwd.exe -cmd:"app.exe" -setcwd:"." -debug
    writer.Write(string.Format("cwd.exe -cmd:\"{0}\" -setcwd:\".\"", AppExeName));
}

