from django.contrib import admin

class CustomModelAdmin(admin.ModelAdmin):
    def get_readonly_fields(self,request,obj=None):
        if not request.user.is_superuser:
            return [f.name for f in self.model._meta.fields]
        return self.readonly_fields