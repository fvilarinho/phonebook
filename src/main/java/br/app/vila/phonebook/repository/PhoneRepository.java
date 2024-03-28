package br.app.vila.phonebook.repository;

import br.app.vila.phonebook.model.Phone;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PhoneRepository extends JpaRepository<Phone, Long> {
    List<Phone> findByNameContainingIgnoreCase(String name);
}